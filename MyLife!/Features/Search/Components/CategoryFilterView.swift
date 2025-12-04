import SwiftUI

struct CategoryFilterView: View {
    let categories: [Category]
    let counts: [Category: Int]
    @Binding var selectedCategory: Category?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "All" Chip (represented by nil)
                FilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    color: .gray
                ) {
                    withAnimation {
                        selectedCategory = nil
                    }
                }
                
                // Category Chips
                ForEach(categories) { category in
                    FilterChip(
                        title: category.name,
                        count: counts[category],
                        isSelected: selectedCategory == category,
                        color: category.color
                    ) {
                        withAnimation {
                            if selectedCategory == category {
                                selectedCategory = nil // Deselect if tapped again
                            } else {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

struct FilterChip: View {
    let title: String
    var count: Int? = nil
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                if let count = count {
                    Text("\(count)")
                        .font(.caption2.weight(.bold))
                        .opacity(0.8)
                }
            }
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        color
                    } else {
                        Color.black.opacity(0.6)
                    }
                }
            )
            .foregroundColor(.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color : Color.white.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    CategoryFilterView(categories: [], counts: [:], selectedCategory: .constant(nil))
        .background(Color.black)
}
