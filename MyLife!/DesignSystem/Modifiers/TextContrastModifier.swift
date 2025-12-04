import SwiftUI

struct TextContrastModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            // Switch to a standard Drop Shadow.
            // This is cleaner, sharper, and doesn't look like a "smudge".
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5) // Softer, wider shadow for depth
    }
}

extension View {
    func textContrast() -> some View {
        self.modifier(TextContrastModifier())
    }
}
