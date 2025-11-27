import SwiftUI
import SwiftData
import UniformTypeIdentifiers

enum SettingsDestination: Hashable {
    case appearance
    case categories
    case people
    case data
}

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var tourManager: TourManager
    @AppStorage("showThumbnails") private var showThumbnails = true
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                themeManager.backgroundView()
                
                Form {
                    Section(header: Text("Timeline Appearance").foregroundColor(themeManager.contrastingTextColor)) {
                        NavigationLink(value: SettingsDestination.appearance) {
                            Label("Appearance", systemImage: "paintpalette")
                                .foregroundColor(themeManager.contrastingTextColor)
                        }
                        
                        Toggle(isOn: $showThumbnails) {
                            Label("Show Event Thumbnails", systemImage: "photo")
                                .foregroundColor(themeManager.contrastingTextColor)
                        }
                        .tint(Color.theme.accent)
                    }
                    .listRowBackground(Color.clear)
                    
                    Section(header: Text("Data Management").foregroundColor(themeManager.contrastingTextColor)) {
                        NavigationLink(value: SettingsDestination.categories) {
                            HStack {
                                Label("Manage Categories", systemImage: "tag")
                                    .foregroundColor(themeManager.contrastingTextColor)
                                
                                if tourManager.currentStep == .settingsHighlightCategories {
                                    Spacer()
                                    Text("Tap Here")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.theme.accent)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.theme.accent.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .listRowBackground(tourManager.currentStep == .settingsHighlightCategories ? Color.theme.accent.opacity(0.1) : Color.clear)
                        
                        NavigationLink(value: SettingsDestination.people) {
                            HStack {
                                Label("Manage People", systemImage: "person.2")
                                    .foregroundColor(themeManager.contrastingTextColor)
                                
                                if tourManager.currentStep == .settingsHighlightPeople {
                                    Spacer()
                                    Text("Tap Here")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.theme.accent)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.theme.accent.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .listRowBackground(tourManager.currentStep == .settingsHighlightPeople ? Color.theme.accent.opacity(0.1) : Color.clear)
                        
                        NavigationLink(value: SettingsDestination.data) {
                            Label("Import / Export JSON", systemImage: "arrow.up.arrow.down")
                                .foregroundColor(themeManager.contrastingTextColor)
                        }
                    }
                    .listRowBackground(Color.clear)
                    
                    Section(header: Text("About").foregroundColor(themeManager.contrastingTextColor)) {
                        HStack {
                            Label("Version", systemImage: "info.circle")
                                .foregroundColor(themeManager.contrastingTextColor)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(themeManager.contrastingTextColor.opacity(0.7))
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .toolbarColorScheme(themeManager.contrastingTextColor == .white ? .dark : .light, for: .navigationBar)
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .appearance:
                    AppearanceSettingsView()
                case .categories:
                    CategoryListView()
                case .people:
                    PeopleListView()
                case .data:
                    DataManagementView()
                }
            }
        }
    }
}
    
    
    #Preview {
        SettingsView()
    }
    
    struct DataManagementView: View {
        @Environment(\.modelContext) private var modelContext
        @Query private var events: [LifeEvent]
        
        @State private var activeSheet: ImportSheetType?
        @State private var isPresentingImporter: Bool = false
        @State private var showingColumnMapper: Bool = false
        @State private var csvContent: String = ""
        @State private var csvHeaders: [String] = []
        
        @State private var jsonText = ""
        @State private var showingAlert = false
        @State private var importMessage = ""
        @State private var importCount = 0
        
        var body: some View {
            Form {
                Section(header: Text("Import from Text")) {
                    Text("Paste JSON content directly to import events.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $jsonText)
                        .frame(height: 100)
                        .font(.caption.monospaced())
                    
                    Button("Import from Text") {
                        let result = DataManager.shared.importJSON(json: jsonText, context: modelContext)
                        importCount = result.importedCount
                        
                        if !result.formatValid {
                            importMessage = "Invalid JSON format."
                        } else {
                            importMessage = "Import:\n\(result.importedCount) new events.\n\(result.duplicateCount) duplicates skipped."
                        }
                        showingAlert = true
                    }
                    .disabled(jsonText.isEmpty)
                }
                
                Section(header: Text("External Services")) {
                    Button {
                        activeSheet = .linkedIn
                        isPresentingImporter = true
                    } label: {
                        Label("Import LinkedIn (Positions.csv)", systemImage: "briefcase")
                    }
                    
                    Button {
                        activeSheet = .instagram
                        isPresentingImporter = true
                    } label: {
                        Label("Import Instagram (media.json)", systemImage: "camera")
                    }
                }
                
                Section(header: Text("Generic Import")) {
                    Button {
                        activeSheet = .generic
                        isPresentingImporter = true
                    } label: {
                        Label("Import from JSON File", systemImage: "square.and.arrow.down")
                    }
                    
                    Button {
                        activeSheet = .genericCSV
                        isPresentingImporter = true
                    } label: {
                        Label("Import from CSV File", systemImage: "tablecells")
                    }
                }
                
                Section(header: Text("Export")) {
                    ShareLink(item: DataManager.shared.exportJSON(events: try! modelContext.fetch(FetchDescriptor<LifeEvent>())) ?? "", preview: SharePreview("MyLife Export", image: Image(systemName: "arrow.up.doc"))) {
                        Label("Export All Data (JSON)", systemImage: "square.and.arrow.up")
                    }
                }
                
                Section(footer: Text("Importing data may create duplicates if events already exist.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Manage Data")
            .fileImporter(
                isPresented: $isPresentingImporter,
                allowedContentTypes: activeSheet == .instagram || activeSheet == .generic ? [.json] : [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result: result)
            }
            .alert("Import Result", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importMessage)
            }
            .sheet(isPresented: $showingColumnMapper) {
                ColumnMappingView(csvHeaders: csvHeaders) { mapping in
                    let result = GenericCSVParser.shared.parse(csvString: csvContent, mapping: mapping, context: modelContext)
                    importCount = result.importedCount
                    
                    if !result.formatValid {
                        importMessage = "Invalid CSV format or missing columns."
                    } else {
                        importMessage = "CSV Import:\n\(result.importedCount) new events.\n\(result.duplicateCount) duplicates skipped."
                    }
                    showingAlert = true
                }
            }
        }
        
        private func handleFileImport(result: Result<[URL], Error>) {
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                
                // Security access
                guard url.startAccessingSecurityScopedResource() else {
                    importMessage = "Permission denied to access file."
                    showingAlert = true
                    return
                }
                
                defer { url.stopAccessingSecurityScopedResource() }
                
                do {
                    let content = try String(contentsOf: url, encoding: .utf8)
                    let currentType = activeSheet
                    
                    // Reset activeSheet to prevent race conditions on next open,
                    // but keep local copy for logic
                    // activeSheet = nil
                    
                    var result = ImportResult()
                    
                    switch currentType {
                    case .linkedIn:
                        let posResult = LinkedInParser.shared.parsePositions(csvString: content, context: modelContext)
                        let eduResult = LinkedInParser.shared.parseEducation(csvString: content, context: modelContext)
                        
                        if !posResult.formatValid && !eduResult.formatValid {
                            // Debugging info
                            let rows = CSVHelper.parse(csvString: content)
                            if let headers = rows.first?.keys {
                                importMessage = "No events imported. Found headers: \(headers.joined(separator: ", "))"
                            } else {
                                importMessage = "No events imported. Could not parse CSV headers."
                            }
                            showingAlert = true
                            return
                        }
                        
                        result.importedCount = posResult.importedCount + eduResult.importedCount
                        result.duplicateCount = posResult.duplicateCount + eduResult.duplicateCount
                        
                        importMessage = "LinkedIn Import:\n\(result.importedCount) new events.\n\(result.duplicateCount) duplicates skipped."
                        importCount = result.importedCount
                        showingAlert = true
                        
                    case .instagram:
                        result = InstagramParser.shared.parseMedia(jsonString: content, context: modelContext)
                        if !result.formatValid {
                            importMessage = "Invalid Instagram JSON format."
                        } else {
                            importMessage = "Instagram Import:\n\(result.importedCount) new memories.\n\(result.duplicateCount) duplicates skipped."
                        }
                        importCount = result.importedCount
                        showingAlert = true
                        
                    case .generic:
                        result = DataManager.shared.importJSON(json: content, context: modelContext)
                        if !result.formatValid {
                            importMessage = "Invalid JSON format."
                        } else {
                            importMessage = "Import:\n\(result.importedCount) new events.\n\(result.duplicateCount) duplicates skipped."
                        }
                        importCount = result.importedCount
                        showingAlert = true
                        
                    case .genericCSV:
                        // Parse headers and show mapper
                        let rows = CSVHelper.parse(csvString: content)
                        if let firstRow = rows.first {
                            csvHeaders = Array(firstRow.keys).sorted()
                            csvContent = content
                            showingColumnMapper = true
                        } else {
                            importMessage = "Could not parse CSV headers."
                            showingAlert = true
                        }
                        
                    case .none:
                        break
                    }
                    
                } catch {
                    importMessage = "Error reading file: \(error.localizedDescription)"
                    showingAlert = true
                }
            case .failure(let error):
                importMessage = "Import failed: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    enum ImportSheetType: Identifiable {
        case generic
        case linkedIn
        case instagram
        case genericCSV
        
        var id: Self { self }
    }
