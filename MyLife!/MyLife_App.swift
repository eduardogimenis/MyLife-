import SwiftUI
import SwiftData

@main
struct MyLife_App: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var tourManager = TourManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LifeEvent.self,
            Category.self,
            Person.self,
            DraftEvent.self,
            ImportedAssetLog.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
        
        // USE A NEW STORE NAME TO RESET DB (Fixes migration freeze)
        let config = ModelConfiguration("MyLife_v2", schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(tourManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
