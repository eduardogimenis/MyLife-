import SwiftUI
import SwiftData

struct GalleryView: View {
    @Query(filter: #Predicate<LifeEvent> { $0.photoID != nil }, sort: \LifeEvent.date, order: .reverse) private var eventsWithPhotos: [LifeEvent]
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \Person.name) private var allPeople: [Person]
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var selectedCategory: Category?
    @State private var selectedPerson: Person?
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var filteredEvents: [LifeEvent] {
        eventsWithPhotos.filter { event in
            let matchesCategory = selectedCategory == nil || event.categoryModel == selectedCategory
            let matchesPerson = selectedPerson == nil || (event.people?.contains(selectedPerson!) ?? false)
            return matchesCategory && matchesPerson
        }
    }
    
    var groupedEvents: [(Int, [LifeEvent])] {
        let grouped = Dictionary(grouping: filteredEvents) { event in
            Calendar.current.component(.year, from: event.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundView()
                
                VStack(spacing: 0) {
                    // Filters
                    VStack(spacing: 0) {
                        CategoryFilterView(categories: categories, selectedCategory: $selectedCategory)
                        
                        if !allPeople.isEmpty {
                            PeopleFilterView(people: allPeople, selectedPerson: $selectedPerson)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(groupedEvents, id: \.0) { year, events in
                                Section(header: 
                                    HStack {
                                        Text(String(year))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(themeManager.contrastingTextColor)
                                            .padding(.vertical, 8)
                                        Spacer()
                                    }
                                ) {
                                    ForEach(events) { event in
                                        if let photoID = event.photoID {
                                            NavigationLink(destination: EventDetailView(event: event)) {
                                                VStack(alignment: .leading) {
                                                    AsyncPhotoView(photoID: photoID)
                                                        .frame(minWidth: 0, maxWidth: .infinity)
                                                        .frame(height: 150)
                                                        .clipped()
                                                        .cornerRadius(12)
                                                    
                                                    Text(event.title)
                                                        .font(.caption)
                                                        .fontWeight(.bold)
                                                        .lineLimit(1)
                                                        .foregroundColor(themeManager.contrastingTextColor)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                    
                                                    Text(event.date.formatted(date: .abbreviated, time: .omitted))
                                                        .font(.caption2)
                                                        .foregroundColor(themeManager.contrastingTextColor.opacity(0.7))
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Gallery")
            .toolbarColorScheme(themeManager.contrastingTextColor == .white ? .dark : .light, for: .navigationBar)
        }
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
        .scrollContentBackground(.hidden)
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
