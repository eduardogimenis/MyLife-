import SwiftUI

struct DebugView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Debug Theme Manager")
                .font(.title)
            
            Text("Current Style: \(themeManager.backgroundStyleRaw)")
            Text("R: \(themeManager.customBackgroundR)")
            Text("G: \(themeManager.customBackgroundG)")
            Text("B: \(themeManager.customBackgroundB)")
            Text("A: \(themeManager.customBackgroundA)")
            
            ColorPicker("Pick Color", selection: Binding(
                get: { themeManager.customBackgroundColor },
                set: { themeManager.setCustomBackgroundColor($0) }
            ))
            
            Button("Set Red Background") {
                themeManager.backgroundStyleRaw = "solid"
                themeManager.setCustomBackgroundColor(.red)
            }
            
            Button("Reset to Default") {
                themeManager.backgroundStyleRaw = "solid"
                // Reset to theme default (which we assume is handled by A=0 or specific logic)
                themeManager.customBackgroundA = 0 // Triggers default logic
            }
        }
        .padding()
        .background(themeManager.backgroundView())
    }
}

#Preview {
    DebugView()
        .environmentObject(ThemeManager())
}
