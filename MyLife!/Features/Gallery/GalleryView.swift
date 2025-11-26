import SwiftUI
import SwiftData

struct GalleryView: View {
    @Query(filter: #Predicate<LifeEvent> { $0.photoID != nil }, sort: \LifeEvent.date, order: .reverse) private var eventsWithPhotos: [LifeEvent]
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(eventsWithPhotos) { event in
                    if let photoID = event.photoID {
                        NavigationLink(destination: EventDetailView(event: event)) {
                            VStack(alignment: .leading) {
                                AsyncPhotoView(photoID: photoID)
                                    .frame(height: 150)
                                    .clipped()
                                    .cornerRadius(12)
                                
                                Text(event.title)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .foregroundColor(.primary)
                                
                                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Gallery")
        .background(Color.theme.background)
    }
}

// Simple Detail View for now
struct EventDetailView: View {
    let event: LifeEvent
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let photoID = event.photoID {
                    AsyncPhotoView(photoID: photoID)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .clipped()
                        .cornerRadius(16)
                }
                
                Text(event.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: "calendar")
                    Text(event.date.formatted(date: .long, time: .omitted))
                }
                .foregroundColor(.secondary)
                
                if let notes = event.notes {
                    Text(notes)
                        .font(.body)
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color.theme.background)
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
