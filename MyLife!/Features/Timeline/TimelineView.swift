import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeManager: ThemeManager
    @Query(sort: \LifeEvent.date, order: .reverse) private var events: [LifeEvent]
    
    @State private var showingAddEvent = false
    @State private var showingInbox = false
    @State private var showingSetupWizard = false
    @State private var selectedEvent: LifeEvent?
    @State private var headerOffset: CGFloat = 0
    
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
                        emptyStateView

                    } else {
                        timelineContent
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showingInbox) {
                InboxView()
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView()
        }
        .sheet(isPresented: $showingSetupWizard) {
            SetupWizardView()
        }

    }
    
    private var emptyStateView: some View {
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
    }
    
    private var timelineContent: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottom) {
                ScrollView {
                    // Editorial Header with Add Button
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("MyLife!")
                                .font(.system(.largeTitle, design: .serif).weight(.bold))
                                .foregroundColor(themeManager.contrastingTextColor)
                                .textContrast()
                            
                            Text("The Journey So Far")
                                .font(.system(.footnote, design: .serif).weight(.medium))
                                .italic()
                                .foregroundColor(themeManager.contrastingTextColor.opacity(0.7))
                                .textContrast()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            print("DEBUG: Inbox button tapped")
                            showingInbox = true
                        }) {
                            Image(systemName: "tray.full.fill")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(themeManager.accentColor)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        
                        Button(action: { showingAddEvent = true }) {
                            Image(systemName: "plus")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(themeManager.accentColor)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .id("timelineTop")
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .background(GeometryReader { geo in
                        Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
                    })
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        headerOffset = value
                    }
                    
                    LazyVStack(spacing: 0) {
                        ForEach(groupedEvents, id: \.0) { year, months in
                            VStack(spacing: 0) {
                                ForEach(months, id: \.0) { monthData in
                                    MonthRowView(
                                        year: year,
                                        month: monthData.0,
                                        events: monthData.1,
                                        isFirstMonth: monthData.0 == months.first?.0
                                    )
                                }
                            }
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                .scrollContentBackground(.hidden)
                
                // Scroll to Top Button
                if headerOffset < -600 {
                    Button(action: {
                        withAnimation {
                            proxy.scrollTo("timelineTop", anchor: .top)
                        }
                    }) {
                        Image(systemName: "arrow.up")
                            .font(.title3.weight(.bold))
                            .foregroundColor(themeManager.contrastingTextColor)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .overlay(
                                Circle()
                                    .stroke(themeManager.contrastingTextColor.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .padding(.bottom, 20)
                    .opacity(0.8)
                    .transition(.scale.combined(with: .opacity))
                }
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

private struct MonthRowView: View {
    let year: Int
    let month: String
    let events: [LifeEvent]
    let isFirstMonth: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Left Rail: Year & Month
            VStack(alignment: .trailing, spacing: 2) {
                // Show Year only for the first month of the year
                if isFirstMonth {
                    Text(String(year))
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.heavy)
                        .foregroundColor(themeManager.contrastingTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.bottom, 2)
                        .textContrast()
                }
                
                Text(month.prefix(3).uppercased())
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundColor(themeManager.contrastingTextColor.opacity(0.6))
                    .textContrast()
            }
            .frame(width: 60, alignment: .trailing)
            .padding(.top, 6)
            
            // Right Rail: Events
            VStack(spacing: 0) {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventCard(event: event, showImage: false)
                            .padding(.bottom, themeManager.timelineDensity == .compact ? 8 : 16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

#Preview {
    TimelineView()
        .modelContainer(for: LifeEvent.self, inMemory: true)
}
