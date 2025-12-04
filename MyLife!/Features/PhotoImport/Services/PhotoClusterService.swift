import Foundation
import Photos
import SwiftData

actor PhotoClusterService {
    static let shared = PhotoClusterService()
    
    struct ScanState: Codable {
        var totalAssets: Int
        var scannedCount: Int
        var lastScannedDate: Date?
        var isScanning: Bool
    }
    
    private let checkpointKey = "PhotoImportCheckpoint"
    
    func requestAuthorization() async -> PHAuthorizationStatus {
        return await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }
    
    func scanLibrary(modelContainer: ModelContainer) async {
        let modelContext = ModelContext(modelContainer)
        modelContext.autosaveEnabled = false // We will save manually
        
        // 1. Load Checkpoint
        var state = loadCheckpoint() ?? ScanState(totalAssets: 0, scannedCount: 0, lastScannedDate: nil, isScanning: true)
        state.isScanning = true
        saveCheckpoint(state)
        
        // 2. Fetch Assets (Reverse Chronological)
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        if let lastDate = state.lastScannedDate {
            fetchOptions.predicate = NSPredicate(format: "creationDate < %@", lastDate as NSDate)
        }
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        state.totalAssets = assets.count // This is just remaining count
        saveCheckpoint(state)
        
        // 3. Iterate and Cluster
        // Fetch already imported IDs to skip duplicates
        let importedDescriptor = FetchDescriptor<ImportedAssetLog>()
        let importedLogs = try? modelContext.fetch(importedDescriptor)
        let importedIDs = Set(importedLogs?.map { $0.assetIdentifier } ?? [])
        
        // Also fetch existing drafts to avoid re-creating them
        let draftDescriptor = FetchDescriptor<DraftEvent>()
        let existingDrafts = try? modelContext.fetch(draftDescriptor)
        let draftIDs = Set(existingDrafts?.flatMap { $0.assetIdentifiers } ?? [])
        
        // Combine into a single exclusion set
        let excludedIDs = importedIDs.union(draftIDs)
        
        var currentCluster: [PHAsset] = []
        var processedCount = 0
        var lastProcessedCoordinate: CLLocationCoordinate2D? = nil
        
        print("Starting scan of \(assets.count) assets...")
        
        for i in 0..<assets.count {
            let asset = assets.object(at: i)
            
            // Skip if already imported or in draft
            if excludedIDs.contains(asset.localIdentifier) {
                continue
            }
            
            // Skip screenshots
            if asset.mediaSubtypes.contains(.photoScreenshot) {
                continue
            }
            
            // Check if belongs to current cluster
            if let lastAsset = currentCluster.last {
                let timeDiff = abs(asset.creationDate?.timeIntervalSince(lastAsset.creationDate ?? Date()) ?? 0)
                let distance = distanceBetween(asset.location, lastAsset.location)
                
                // Rules: Same Calendar Day. Location is ignored to allow "Trips" (moving between cities) to group.
                let isSameDay = Calendar.current.isDate(asset.creationDate ?? Date(), inSameDayAs: lastAsset.creationDate ?? Date())
                
                if isSameDay {
                    currentCluster.append(asset)
                } else {
                    // Finalize previous cluster
                    if let newCoord = await processCluster(currentCluster, modelContext: modelContext, lastCoordinate: lastProcessedCoordinate) {
                        lastProcessedCoordinate = newCoord
                    }
                    currentCluster = [asset]
                }
            } else {
                currentCluster = [asset]
            }
            
            // Update Progress & Checkpoint every 50 assets
            processedCount += 1
            if processedCount % 50 == 0 {
                state.scannedCount += 50
                state.lastScannedDate = asset.creationDate
                saveCheckpoint(state)
                // Yield to keep UI responsive
                await Task.yield()
            }
        }
        
        // Finalize last cluster
        await processCluster(currentCluster, modelContext: modelContext, lastCoordinate: lastProcessedCoordinate)
        
        state.isScanning = false
        saveCheckpoint(state)
    }
    
    @discardableResult
    private func processCluster(_ assets: [PHAsset], modelContext: ModelContext, lastCoordinate: CLLocationCoordinate2D?) async -> CLLocationCoordinate2D? {
        guard !assets.isEmpty else { return nil }
        
        // 1. Identify Sub-Clusters by Location (e.g., > 20km apart)
        let locationGroups = clusterByLocation(assets, threshold: 20_000)
        
        // 2. Geocode each group
        var cities: Set<String> = []
        var countries: Set<String> = []
        var validCoordinates: [CLLocationCoordinate2D] = []
        
        for group in locationGroups {
            if let first = group.first, let loc = first.location {
                validCoordinates.append(loc.coordinate)
                let details = await GeocodingService.shared.reverseGeocodeDetails(location: loc)
                if let city = details.city { cities.insert(city) }
                if let country = details.country { countries.insert(country) }
            }
        }
        
        // 3. Determine Title and Notes
        var title = "New Memory"
        var notes: String? = "Imported from Photos"
        
        if !cities.isEmpty {
            if cities.count == 1 {
                let city = cities.first!
                if let country = countries.first {
                    title = "\(city), \(country)"
                } else {
                    title = city
                }
            } else {
                // Multiple Cities
                if countries.count == 1 {
                    title = countries.first!
                } else {
                    title = "Euro Trip" // Fallback or "Multiple Countries"
                    if let firstCountry = countries.first { title = "\(firstCountry) Trip" }
                }
                
                let cityList = cities.sorted().joined(separator: ", ")
                notes = "Visited: \(cityList)"
            }
        } else if !countries.isEmpty {
             title = countries.first!
        }
        
        // 4. Calculate Centroid for Event Location
        var coordinate: CLLocationCoordinate2D? = nil
        if !validCoordinates.isEmpty {
            let lat = validCoordinates.map { $0.latitude }.reduce(0, +) / Double(validCoordinates.count)
            let long = validCoordinates.map { $0.longitude }.reduce(0, +) / Double(validCoordinates.count)
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        // Dynamic Threshold Logic
        // Default: 5 photos
        // If distance > 50km from last event: 1 photo (Trip/Travel)
        var minPhotos = 5
        
        if let currentCoord = coordinate, let lastCoord = lastCoordinate {
            let loc1 = CLLocation(latitude: currentCoord.latitude, longitude: currentCoord.longitude)
            let loc2 = CLLocation(latitude: lastCoord.latitude, longitude: lastCoord.longitude)
            let distance = loc1.distance(from: loc2)
            
            if distance > 50_000 { // 50km
                minPhotos = 1
                print("Significant location change detected (\(Int(distance/1000))km). Lowering threshold to 1.")
            }
        }
        
        guard assets.count >= minPhotos else { return coordinate }
        
        // Create Draft
        // Use the date of the *middle* asset as the event date (or first)
        let eventDate = assets[assets.count / 2].creationDate ?? Date()
        let assetIDs = assets.map { $0.localIdentifier }
        
        let draft = DraftEvent(
            date: eventDate,
            assetIdentifiers: assetIDs,
            locationName: title,
            coordinate: coordinate,
            notes: notes
        )
        
        modelContext.insert(draft)
        try? modelContext.save()
        print("Created draft event: \(draft.locationName ?? "Unknown") with \(assetIDs.count) photos")
        
        return coordinate
    }
    
    private func clusterByLocation(_ assets: [PHAsset], threshold: CLLocationDistance) -> [[PHAsset]] {
        var groups: [[PHAsset]] = []
        
        for asset in assets {
            guard let loc = asset.location else { continue }
            
            var added = false
            for i in 0..<groups.count {
                if let first = groups[i].first, let firstLoc = first.location {
                    if firstLoc.distance(from: loc) < threshold {
                        groups[i].append(asset)
                        added = true
                        break
                    }
                }
            }
            
            if !added {
                groups.append([asset])
            }
        }
        
        // If no location assets, just return one group of all assets? 
        // Or empty? The caller handles empty.
        // But we need to preserve assets without location?
        // Actually, for geocoding purposes, we only care about assets WITH location.
        // But for the EVENT, we want ALL assets.
        // So this helper is just for finding locations.
        return groups
    }
    
    private func distanceBetween(_ loc1: CLLocation?, _ loc2: CLLocation?) -> CLLocationDistance {
        guard let l1 = loc1, let l2 = loc2 else { return 0 }
        return l1.distance(from: l2)
    }
    
    private func loadCheckpoint() -> ScanState? {
        guard let data = UserDefaults.standard.data(forKey: checkpointKey) else { return nil }
        return try? JSONDecoder().decode(ScanState.self, from: data)
    }
    
    private func saveCheckpoint(_ state: ScanState) {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: checkpointKey)
        }
    }
    
    func resetProgress() {
        UserDefaults.standard.removeObject(forKey: checkpointKey)
    }
    
    func resetAnalysisHistory(modelContainer: ModelContainer) async {
        let context = ModelContext(modelContainer)
        context.autosaveEnabled = false
        
        do {
            try context.delete(model: ImportedAssetLog.self)
            try context.delete(model: DraftEvent.self)
            try context.save()
            resetProgress()
            print("Analysis history reset.")
        } catch {
            print("Failed to reset analysis history: \(error)")
        }
    }
}
