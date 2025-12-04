import SwiftUI
import SwiftData
import Photos

struct ReviewClusterView: View {
    let draft: DraftEvent
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeManager: ThemeManager
    
    @Query private var categories: [Category]
    @State private var selectedAssets: Set<String> = []
    @State private var selectedCategory: EventCategory = .travel
    @State private var userNotes: String = ""
    @State private var gridColumns = [GridItem(.adaptive(minimum: 90), spacing: 4)]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(draft.locationName ?? "Unknown Location")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.contrastingTextColor)
                        
                        Text(draft.date.formatted(date: .long, time: .omitted))
                            .font(.title3)
                            .foregroundColor(themeManager.contrastingTextColor.opacity(0.7))
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Category Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.headline)
                            .foregroundColor(themeManager.contrastingTextColor)
                        
                        HStack {
                            Image(systemName: selectedCategory.iconName)
                                .foregroundColor(selectedCategory.color)
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(EventCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(themeManager.contrastingTextColor)
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Note Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                            .font(.headline)
                            .foregroundColor(themeManager.contrastingTextColor)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Add a note...", text: $userNotes, axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            
                            if let existingNotes = draft.notes {
                                Text(existingNotes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Photos Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Select Photos")
                                .font(.headline)
                                .foregroundColor(themeManager.contrastingTextColor)
                            Spacer()
                            Text("\(selectedAssets.count) selected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: gridColumns, spacing: 4) {
                            ForEach(draft.assetIdentifiers, id: \.self) { assetID in
                                AssetThumbnail(assetIdentifier: assetID)
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                                    .cornerRadius(4)
                                    .overlay(
                                        ZStack {
                                            if selectedAssets.contains(assetID) {
                                                Color.black.opacity(0.3)
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    )
                                    .onTapGesture {
                                        toggleSelection(assetID)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 100) // Space for bottom bar
            }
            
            // Bottom Bar
            VStack(spacing: 12) {
                Text("\(selectedAssets.count) selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Button(role: .destructive) {
                        deleteDraft()
                    } label: {
                        Text("Delete Event")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    Button {
                        importMemory()
                    } label: {
                        Text("Add to Timeline")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedAssets.isEmpty ? Color.gray : themeManager.accentColor)
                            .cornerRadius(12)
                    }
                    .disabled(selectedAssets.isEmpty)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .background(themeManager.backgroundView())
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleSelection(_ id: String) {
        if selectedAssets.contains(id) {
            selectedAssets.remove(id)
        } else {
            if selectedAssets.count < 20 {
                selectedAssets.insert(id)
            }
        }
    }

    private func importMemory() {
        // 1. Find matching Category model
        let categoryModel = categories.first { $0.name == selectedCategory.rawValue }
        
        // Combine notes
        var finalNotes = userNotes
        if let autoNotes = draft.notes, !autoNotes.isEmpty {
            if !finalNotes.isEmpty {
                finalNotes += "\n\n"
            }
            finalNotes += autoNotes
        }
        
        // 2. Create LifeEvent
        let newEvent = LifeEvent(
            title: draft.locationName ?? "New Memory",
            date: draft.date,
            category: selectedCategory,
            notes: finalNotes.isEmpty ? nil : finalNotes,
            categoryModel: categoryModel
        )
        // Ensure raw value is synced if init doesn't do it (it should, but safety first)
        if let model = categoryModel {
            newEvent.categoryRawValue = model.name
        }
        
        // 2. Link Photos
        newEvent.photoIDs = Array(selectedAssets)
        newEvent.photoID = newEvent.photoIDs.first // Sync legacy field for Gallery query
        
        // 3. Save to Context
        modelContext.insert(newEvent)
        
        // 4. Log Imported Assets (to prevent re-import)
        for assetID in selectedAssets {
            let log = ImportedAssetLog(assetIdentifier: assetID)
            modelContext.insert(log)
        }
        
        // 5. Delete Draft
        modelContext.delete(draft)
        
        dismiss()
    }
    
    private func deleteDraft() {
        // Mark assets as imported/ignored so they don't reappear
        for assetID in draft.assetIdentifiers {
            let log = ImportedAssetLog(assetIdentifier: assetID)
            modelContext.insert(log)
        }
        
        // Delete the draft
        modelContext.delete(draft)
        
        dismiss()
    }
}

struct AssetThumbnail: View {
    let assetIdentifier: String
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(ProgressView())
            }
        }
        .onAppear {
            loadAsset()
        }
    }
    
    private func loadAsset() {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
        guard let asset = assets.firstObject else { return }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        let targetSize = CGSize(width: 200, height: 200) // Thumbnail size
        
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { result, _ in
            if let result = result {
                self.image = result
            }
        }
    }
}
