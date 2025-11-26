import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let background = Color("Background") // Define in Assets
    let accent = Color("AccentColor") // Define in Assets
    let secondaryText = Color.gray
    
    // Semantic Colors
    let work = Color.blue
    let living = Color.green
    let travel = Color.orange
    let event = Color.purple
    
    let cardBackground = Color.black.opacity(0.3)
}
