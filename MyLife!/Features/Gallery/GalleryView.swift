import SwiftUI
import SwiftData

struct GalleryView: View {
    @Query(filter: #Predicate<LifeEvent> { $0.photoID != nil }, sort: \LifeEvent.date, order: .reverse) private var eventsWithPhotos: [LifeEvent]
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \Person.name) private var allPeople: [Person]
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var selectedCategory: Category?
    @State private var selectedPerson: Person?
    
    @State private var navigationPath = NavigationPath()
    
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
    
    var categoryCounts: [Category: Int] {
        var counts: [Category: Int] = [:]
        for event in eventsWithPhotos {
            if let category = event.categoryModel {
                counts[category, default: 0] += 1
            }
        }
        return counts
    }
    
    var personCounts: [Person: Int] {
        var counts: [Person: Int] = [:]
        for event in eventsWithPhotos {
            if let people = event.people {
                for person in people {
                    counts[person, default: 0] += 1
                }
            }
        }
        return counts
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                themeManager.backgroundView()
                
                VStack(spacing: 0) {
                    // Filters
                    VStack(spacing: 0) {
                        CategoryFilterView(categories: categories, counts: categoryCounts, selectedCategory: $selectedCategory)
                        
                        if !allPeople.isEmpty {
                            PeopleFilterView(people: allPeople, counts: personCounts, selectedPerson: $selectedPerson)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(groupedEvents, id: \.0) { year, events in
                                Section(header: 
                                    HStack {
                                        Text(String(year))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(themeManager.contrastingTextColor)
                                            .padding(.vertical, 8)
                                            .textContrast()
                                        Spacer()
                                    }
                                ) {
                                    ForEach(events) { event in
                                        if let photoID = event.photoIDs.first ?? event.photoID {
                                            VStack(alignment: .leading) {
                                                PhotoStackView(
                                                    photoIDs: !event.photoIDs.isEmpty ? event.photoIDs : [photoID],
                                                    onTap: { navigationPath.append(event) }
                                                )
                                                .frame(height: 150)
                                                
                                                Text(event.title)
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .lineLimit(1)
                                                    .foregroundColor(themeManager.contrastingTextColor)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.top, 4)
                                                    .textContrast()
                                                
                                                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                                                    .font(.caption2)
                                                    .foregroundColor(themeManager.contrastingTextColor.opacity(0.7))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .textContrast()
                                            }
                                            .onTapGesture {
                                                navigationPath.append(event)
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
            .navigationDestination(for: LifeEvent.self) { event in
                EventDetailView(event: event)
            }
        }
    }
}

struct PhotoStackView: View {
    let photoIDs: [String]
    let onTap: () -> Void
    
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        let count = photoIDs.count
        let currentID = count > 0 ? photoIDs[currentIndex % count] : nil
        let nextID = count > 1 ? photoIDs[(currentIndex + 1) % count] : nil
        
        return ZStack {
            // Background/Next Card
            if let nextID = nextID {
                AsyncPhotoView(photoID: nextID)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(12)
                    .rotationEffect(.degrees(3))
                    .scaleEffect(0.95)
            }
            
            // Top Card
            if let currentID = currentID {
                AsyncPhotoView(photoID: currentID)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .offset(offset)
                    .rotationEffect(.degrees(Double(offset.width / 10)))
                    .id(currentIndex) // Force view refresh on index change
                    .gesture(
                        count > 1 ?
                        DragGesture()
                            .onChanged { gesture in
                                offset = gesture.translation
                            }
                            .onEnded { gesture in
                                if abs(gesture.translation.width) > 50 {
                                    // Swipe away
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        offset.width = gesture.translation.width > 0 ? 500 : -500
                                    }
                                    
                                    // Reset and increment
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        currentIndex += 1
                                        offset = .zero
                                    }
                                } else {
                                    // Snap back
                                    withAnimation(.spring()) {
                                        offset = .zero
                                    }
                                }
                            }
                        : nil
                    )
                    .onTapGesture {
                        onTap()
                    }
            }
            
            // Badge
            if count > 1 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(count)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .padding(4)
                    }
                }
            }
        }
    }
}

// Simple Detail View for now

