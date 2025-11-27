import SwiftUI
import SwiftData

@main
struct MyLife_App: App {
    @StateObject private var themeManager = ThemeManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LifeEvent.self,
            Category.self,
            Person.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
