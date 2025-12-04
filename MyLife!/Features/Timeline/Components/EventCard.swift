import SwiftUI
import Photos

struct EventCard: View {
    let event: LifeEvent
    var showImage: Bool = true
    @EnvironmentObject var themeManager: ThemeManager

    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.contrastingTextColor)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(height: 22, alignment: .leading)
                
                // Location removed to optimize space in timeline list
                
                if let endDate = event.endDate {
                    Text("\(event.date.formatted(.dateTime.month(.abbreviated).day())) - \(endDate.formatted(.dateTime.month(.abbreviated).day()))")
                        .font(.caption2)
                        .foregroundColor(themeManager.contrastingTextColor.opacity(0.6))
                        .lineLimit(1)
                } else {
                    Text(event.date.formatted(.dateTime.month(.abbreviated).day()))
                        .font(.caption2)
                        .foregroundColor(themeManager.contrastingTextColor.opacity(0.6))
                        .lineLimit(1)
                }
                
                // Photo Thumbnail
                if showImage, let photoID = event.photoIDs.first ?? event.photoID {
                    ZStack(alignment: .bottomTrailing) {
                        AsyncPhotoView(photoID: photoID)
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(8)
                        
                        if event.photoIDs.count > 1 {
                            Text("+\(event.photoIDs.count - 1)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .padding(8)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .frame(height: 45, alignment: .topLeading)
            Spacer()
            
            // Category Icon
            VStack(alignment: .trailing, spacing: 4) {
                if let category = event.categoryModel {
                    Image(systemName: category.iconName)
                        .foregroundColor(category.color.opacity(0.7))
                        .font(.caption)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: event.category.rawValue == "Event" ? "star.fill" : "circle.fill") // Fallback
                         .foregroundColor(event.category.color.opacity(0.7))
                         .font(.caption)
                         .frame(width: 24, height: 24)
                }
            }
        }
        .glassCard(tint: (event.categoryModel?.color ?? event.category.color).opacity(0.07))
    }
}

struct AsyncPhotoView: View {
    let photoID: String
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.black.opacity(0.2))
                    .overlay(ProgressView())
            }
        }
        .onAppear {
            loadPhoto()
        }
    }
    
    private func loadPhoto() {
        // 1. Try loading from PhotoKit (for imported assets)
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [photoID], options: nil)
        if let asset = assets.firstObject {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = false // Async for UI
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = true
            
            // Request a reasonable size (e.g., 500px)
            let targetSize = CGSize(width: 500, height: 500)
            
            manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { result, _ in
                if let result = result {
                    DispatchQueue.main.async {
                        withAnimation {
                            self.image = result
                        }
                    }
                }
            }
            return
        }
        
        // 2. Fallback to Disk (for manually added assets)
        DispatchQueue.global(qos: .userInitiated).async {
            let loadedImage = PhotoManager.shared.loadImage(filename: photoID)
            DispatchQueue.main.async {
                withAnimation {
                    self.image = loadedImage
                }
            }
        }
    }
}
