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
    
    var categoryCounts: [Category: Int] {
        var counts: [Category: Int] = [:]
        for event in events {
            if let category = event.categoryModel {
                counts[category, default: 0] += 1
            }
        }
        return counts
    }
    
    var personCounts: [Person: Int] {
        var counts: [Person: Int] = [:]
        for event in events {
            if let people = event.people {
                for person in people {
                    counts[person, default: 0] += 1
                }
            }
        }
        return counts
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundView()
                
                VStack(spacing: 0) {
                    // Filters
                    VStack(spacing: 0) {
                        CategoryFilterView(categories: categories, counts: categoryCounts, selectedCategory: $selectedCategory)
                        
                        if !allPeople.isEmpty {
                            PeopleFilterView(people: allPeople, counts: personCounts, selectedPerson: $selectedPerson)
                        }
                        
                        HStack {
                            Text("\(filteredEvents.count) events found")
                                .font(.caption)
                                .foregroundColor(themeManager.contrastingTextColor.opacity(0.6))
                                .textContrast()
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .padding(.bottom, 8)
                    
                    if filteredEvents.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredEvents) { event in
                                    NavigationLink(destination: EventDetailView(event: event)) {
                                        EventCard(event: event, showImage: false)
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
