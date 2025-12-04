import SwiftUI

struct EventCard: View {
    let event: LifeEvent
    var showImage: Bool = true
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("showThumbnails") private var showThumbnails = true
    
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
                if showImage && showThumbnails, let photoID = event.photoIDs.first ?? event.photoID {
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
            // Use the new synchronous load for disk images, or async wrapper
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
}
