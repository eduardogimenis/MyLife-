import SwiftUI

struct TimelineNode: View {
    let isApproximate: Bool
    let category: Category?
    let fallbackCategory: EventCategory
    
    @EnvironmentObject var themeManager: ThemeManager
    
    init(isApproximate: Bool, category: Category?, fallbackCategory: EventCategory = .event) {
        self.isApproximate = isApproximate
        self.category = category
        self.fallbackCategory = fallbackCategory
    }
    
    var body: some View {
        ZStack {
            // Glow effect for approximate events
            if isApproximate {
                Circle()
                    .fill(categoryColor.opacity(0.4))
                    .frame(width: 24, height: 24)
                    .blur(radius: 4)
            }
            
            // Core Node
            Circle()
                .fill(categoryColor)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(themeManager.customBackgroundColor, lineWidth: 2)
                )
        }
        .frame(width: 40) // Fixed width for alignment
    }
    
    var categoryColor: Color {
        if let cat = category {
            return cat.color
        }
        return fallbackCategory.color
    }
}

#Preview {
    VStack {
        TimelineNode(isApproximate: false, category: nil, fallbackCategory: .work)
        TimelineNode(isApproximate: true, category: nil, fallbackCategory: .travel)
    }
}
