import SwiftUI

struct EventCard: View {
    let event: LifeEvent
    @AppStorage("showThumbnails") private var showThumbnails = true
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                if let location = event.locationName {
                    Text(location)
                        .font(.captionText)
                        .foregroundColor(.gray)
                }
                
                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(Color.theme.accent)
                
                // Photo Thumbnail
                if showThumbnails, let photoID = event.photoID {
                    AsyncPhotoView(photoID: photoID)
                        .frame(height: 120)
                        .cornerRadius(8)
                        .padding(.top, 4)
                }
            }
            Spacer()
            
            // Category Icon & People
            VStack(alignment: .trailing, spacing: 4) {
                if let category = event.categoryModel {
                    Image(systemName: category.iconName)
                        .foregroundColor(category.color.opacity(0.7))
                        .font(.caption)
                } else {
                    Image(systemName: event.category.rawValue == "Event" ? "star.fill" : "circle.fill") // Fallback
                         .foregroundColor(event.category.color.opacity(0.7))
                         .font(.caption)
                }
                
                if let people = event.people, !people.isEmpty {
                    HStack(spacing: -4) {
                        ForEach(people.prefix(3)) { person in
                            Text(person.emoji)
                                .font(.caption2)
                                .padding(2)
                                .background(Circle().fill(Color.theme.cardBackground))
                        }
                        if people.count > 3 {
                            Text("+\(people.count - 3)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .glassCard()
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
