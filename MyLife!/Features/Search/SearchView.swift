import SwiftUI
import SwiftData

struct SearchView: View {
    @Query(sort: \LifeEvent.date, order: .reverse) private var events: [LifeEvent]
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    
    var filteredEvents: [LifeEvent] {
        events.filter { event in
            let matchesSearch = searchText.isEmpty ||
                event.title.localizedCaseInsensitiveContains(searchText) ||
                (event.notes?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (event.locationName?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesCategory = selectedCategory == nil || event.categoryModel == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                CategoryFilterView(categories: categories, selectedCategory: $selectedCategory)
                    .background(Color.theme.background)
                
                if filteredEvents.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredEvents) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    EventCard(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color.theme.background)
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search memories, notes, places...")
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: LifeEvent.self, inMemory: true)
}
