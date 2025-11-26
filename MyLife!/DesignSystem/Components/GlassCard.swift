import SwiftUI

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassCard() -> some View {
        self.modifier(GlassCard())
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        Text("Glassmorphism")
            .font(.sectionHeader)
            .glassCard()
    }
}
