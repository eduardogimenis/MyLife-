import SwiftUI
import SwiftData

struct SearchView: View {
    @Query(sort: \LifeEvent.date, order: .reverse) private var events: [LifeEvent]
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \Person.name) private var allPeople: [Person]
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedPerson: Person?
    
    var filteredEvents: [LifeEvent] {
        events.filter { event in
            let matchesSearch = searchText.isEmpty ||
                event.title.localizedCaseInsensitiveContains(searchText) ||
                (event.notes?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (event.locationName?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesCategory = selectedCategory == nil || event.categoryModel == selectedCategory
            
            let matchesPerson = selectedPerson == nil || (event.people?.contains(selectedPerson!) ?? false)
            
            return matchesSearch && matchesCategory && matchesPerson
        }
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
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Search")
            .toolbarColorScheme(themeManager.contrastingTextColor == .white ? .dark : .light, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search memories, notes, places...")
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: LifeEvent.self, inMemory: true)
}
