import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeManager: ThemeManager
    @Query(sort: \LifeEvent.date, order: .reverse) private var events: [LifeEvent]
    
    @State private var showingAddEvent = false
    @State private var showingSetupWizard = false
    @State private var selectedEvent: LifeEvent?
    
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
                            LazyVStack(spacing: themeManager.timelineDensity == .compact ? 0 : 16) {
                                ForEach(events) { event in
                                    HStack(alignment: .top, spacing: 0) {
                                        // Node Column
                                        VStack(spacing: 0) {
                                            TimelineNode(isApproximate: event.isApproximate, category: event.categoryModel, fallbackCategory: event.category)
                                            
                                            // Connector Line
                                            if event != events.last {
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
                                            .contentShape(Rectangle())
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
        .sheet(item: $selectedEvent) { event in
            AddEventView(eventToEdit: event)
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
