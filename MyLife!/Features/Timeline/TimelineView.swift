import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeManager: ThemeManager
    @Query(sort: \LifeEvent.date, order: .reverse) private var events: [LifeEvent]
    
    @State private var showingAddEvent = false
    @State private var showingSetupWizard = false
    @State private var selectedEvent: LifeEvent?
    
    var groupedEvents: [(Int, [(String, [LifeEvent])])] {
        let groupedByYear = Dictionary(grouping: events) { event in
            Calendar.current.component(.year, from: event.date)
        }
        
        return groupedByYear.sorted { $0.key > $1.key }.map { year, yearEvents in
            let groupedByMonth = Dictionary(grouping: yearEvents) { event in
                event.date.formatted(.dateTime.month(.wide))
            }
            let sortedMonths = groupedByMonth.sorted {
                let date1 = $0.value.first?.date ?? Date()
                let date2 = $1.value.first?.date ?? Date()
                return date1 > date2
            }
            return (year, sortedMonths)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundView()
                
                VStack(spacing: 0) {
                    if events.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundColor(themeManager.accentColor)
                                .padding(.bottom, 10)
                            
                            Text("Welcome to your Timeline")
                                .font(.system(.title2, design: themeManager.fontDesign))
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.contrastingTextColor)
                            
                            Text("It looks a bit empty. Let's add your major milestones.")
                                .font(.system(.body, design: themeManager.fontDesign))
                                .multilineTextAlignment(.center)
                                .foregroundColor(themeManager.contrastingTextColor.opacity(0.8))
                                .padding(.horizontal)
                            
                            Button("Start Setup") {
                                showingSetupWizard = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(themeManager.accentColor)
                            .padding(.top, 10)
                            
                            Button("Load Mock Data") {
                                loadMockData()
                            }
                            .font(.caption)
                            .foregroundColor(themeManager.contrastingTextColor.opacity(0.6))
                            .padding(.top, 20)
                        }
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(action: { showingAddEvent = true }) {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(groupedEvents, id: \.0) { year, months in
                                    VStack(alignment: .leading, spacing: 0) {
                                        // Year Header
                                        Text(String(year))
                                            .font(.system(.title2, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(themeManager.contrastingTextColor)
                                            .padding(.horizontal)
                                            .padding(.top, 24)
                                            .padding(.bottom, 8)
                                        
                                        ForEach(months, id: \.0) { month, monthEvents in
                                            VStack(alignment: .leading, spacing: 0) {
                                                // Month Header
                                                Text(month)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(themeManager.accentColor)
                                                    .padding(.horizontal)
                                                    .padding(.top, 8)
                                                    .padding(.bottom, 12)
                                                
                                                ForEach(monthEvents) { event in
                                                    NavigationLink(destination: EventDetailView(event: event)) {
                                                        HStack(alignment: .top, spacing: 0) {
                                                            // Node Column
                                                            VStack(spacing: 0) {
                                                                TimelineNode(isApproximate: event.isApproximate, category: event.categoryModel, fallbackCategory: event.category)
                                                                
                                                                // Connector Line
                                                                if event != monthEvents.last || month != months.last?.0 {
                                                                    Rectangle()
                                                                        .fill(Color.gray.opacity(0.3))
                                                                        .frame(width: 2)
                                                                        .frame(minHeight: themeManager.timelineDensity == .compact ? 20 : 40)
                                                                }
                                                            }
                                                            
                                                            // Content Column
                                                            EventCard(event: event)
                                                                .padding(.bottom, themeManager.timelineDensity == .compact ? 8 : 20)
                                                                .padding(.leading, 8)
                                                        }
                                                        .padding(.horizontal)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top)
                        }
                        .scrollContentBackground(.hidden)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button(action: { showingAddEvent = true }) {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(events.isEmpty ? "" : "MyLife!")
            .toolbarColorScheme(themeManager.contrastingTextColor == .black ? .light : .dark, for: .navigationBar)
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView()
        }
        .sheet(isPresented: $showingSetupWizard) {
            SetupWizardView()
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
