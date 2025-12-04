import SwiftUI

struct GlassCard: ViewModifier {
    var tint: Color?
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background {
                ZStack {
                    if let tint {
                        tint
                    }
                    Rectangle().fill(.ultraThinMaterial)
                }
            }
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassCard(tint: Color? = nil) -> some View {
        self.modifier(GlassCard(tint: tint))
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
