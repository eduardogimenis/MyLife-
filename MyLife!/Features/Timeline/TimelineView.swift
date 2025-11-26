import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LifeEvent.date, order: .reverse) private var events: [LifeEvent]
    
    @State private var showingAddEvent = false
    @State private var selectedEvent: LifeEvent?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                if events.isEmpty {
                    ContentUnavailableView("No Events", systemImage: "clock", description: Text("Add your first life event or load sample data."))
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Load Mock Data") {
                                    loadMockData()
                                }
                            }
                            ToolbarItem(placement: .topBarLeading) {
                                Button(action: { showingAddEvent = true }) {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(events) { event in
                                HStack(alignment: .top, spacing: 0) {
                                    // Time Column (Year)
                                    // Ideally we group by year, but for MVP simple list first
                                    
                                    // Node Column
                                    VStack(spacing: 0) {
                                        TimelineNode(isApproximate: event.isApproximate, category: event.categoryModel, fallbackCategory: event.category)
                                        
                                        // Connector Line
                                        if event != events.last {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 2)
                                                .frame(minHeight: 40)
                                        }
                                    }
                                    
                                    // Content Column
                                    EventCard(event: event)
                                        .padding(.bottom, 20)
                                        .padding(.leading, 8)
                                        .contentShape(Rectangle()) // Make entire card area tappable
                                        .onTapGesture {
                                            selectedEvent = event
                                        }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                deleteEvent(event)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            
                                            Button {
                                                selectedEvent = event
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                        }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                    .navigationTitle("MyLife!")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { showingAddEvent = true }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView()
            }
            .sheet(item: $selectedEvent) { event in
                AddEventView(eventToEdit: event)
            }
        }
    }
    
    private func deleteEvent(_ event: LifeEvent) {
        modelContext.delete(event)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func loadMockData() {
        // Fetch existing categories to link
        var categoryMap: [String: Category] = [:]
        if let categories = try? modelContext.fetch(FetchDescriptor<Category>()) {
            for cat in categories {
                categoryMap[cat.name] = cat
            }
        }
        
        let sampleEvents = MockData.generateSampleEvents()
        for event in sampleEvents {
            // Link to category model
            if let cat = categoryMap[event.category.rawValue] {
                event.categoryModel = cat
            }
            modelContext.insert(event)
        }
    }
}

#Preview {
    TimelineView()
        .modelContainer(for: LifeEvent.self, inMemory: true)
}
