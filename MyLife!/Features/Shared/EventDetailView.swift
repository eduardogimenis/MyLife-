import SwiftUI
import SwiftData

struct EventDetailView: View {
    let event: LifeEvent
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingEditSheet = false
    
    var body: some View {
        ZStack {
            themeManager.backgroundView()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Photo Carousel
                    if !event.photoIDs.isEmpty {
                        TabView {
                            ForEach(event.photoIDs, id: \.self) { photoID in
                                AsyncPhotoView(photoID: photoID)
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(16)
                                    .padding(.horizontal)
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(height: 400)
                    } else if let photoID = event.photoID {
                        AsyncPhotoView(photoID: photoID)
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(16)
                            .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(event.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.contrastingTextColor)
                        
                        HStack {
                            Image(systemName: "calendar")
                            if let endDate = event.endDate {
                                Text("\(event.date.formatted(date: .long, time: .omitted)) - \(endDate.formatted(date: .long, time: .omitted))")
                            } else {
                                Text(event.date.formatted(date: .long, time: .omitted))
                            }
                        }
                        .foregroundColor(themeManager.contrastingTextColor.opacity(0.8))
                        
                        if let location = event.locationName {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text(location)
                            }
                            .foregroundColor(themeManager.contrastingTextColor.opacity(0.8))
                        }
                        
                        if let notes = event.notes {
                            Text(notes)
                                .font(.body)
                                .foregroundColor(themeManager.contrastingTextColor)
                                .padding(.top, 8)
                        }
                        
                        // Category & People Tags
                        HStack {
                            if let category = event.categoryModel {
                                HStack {
                                    Image(systemName: category.iconName)
                                    Text(category.name)
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(category.color.opacity(0.2))
                                .foregroundColor(category.color)
                                .cornerRadius(12)
                            }
                            
                            if let people = event.people {
                                ForEach(people) { person in
                                    HStack(spacing: 4) {
                                        Text(person.emoji)
                                        Text(person.name)
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.theme.cardBackground)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddEventView(eventToEdit: event)
        }
        .onChange(of: event.isDeleted) { _, isDeleted in
            if isDeleted {
                dismiss()
            }
        }
    }
}
