import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        MainTabView()
            .preferredColorScheme(themeManager.contrastingTextColor == .black ? .light : .dark)
            .fontDesign(themeManager.fontDesign)
            .dynamicTypeSize(themeManager.dynamicTypeSize)
            .onAppear {
                MigrationManager.shared.performMigration(modelContext: modelContext)
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
