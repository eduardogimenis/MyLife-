import SwiftData
import Foundation
import CoreLocation

enum ImportStatus: String, Codable {
    case pending
    case ignored
    case imported
}

@Model
class DraftEvent {
    var id: UUID
    var date: Date
    var assetIdentifiers: [String]
    var locationName: String?
    var coordinateLat: Double?
    var coordinateLong: Double?
    var statusRaw: String
    var creationDate: Date
    var notes: String?
    
    @Transient
    var status: ImportStatus {
        get { ImportStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }
    
    init(date: Date, assetIdentifiers: [String], locationName: String? = nil, coordinate: CLLocationCoordinate2D? = nil, notes: String? = nil) {
        self.id = UUID()
        self.date = date
        self.assetIdentifiers = assetIdentifiers
        self.locationName = locationName
        self.coordinateLat = coordinate?.latitude
        self.coordinateLong = coordinate?.longitude
        self.notes = notes
        self.statusRaw = ImportStatus.pending.rawValue
        self.creationDate = Date()
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = coordinateLat, let long = coordinateLong else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}

@Model
class ImportedAssetLog {
    @Attribute(.unique) var assetIdentifier: String
    var importDate: Date
    
    init(assetIdentifier: String) {
        self.assetIdentifier = assetIdentifier
        self.importDate = Date()
    }
}
