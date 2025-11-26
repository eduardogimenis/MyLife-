import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
            .preferredColorScheme(.dark) // Enforce dark mode for MVP as per spec
    }
}

#Preview {
    ContentView()
}
