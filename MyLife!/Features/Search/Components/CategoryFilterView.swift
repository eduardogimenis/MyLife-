import SwiftUI

struct CategoryFilterView: View {
    let categories: [Category]
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
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        if isSelected {
                            color
                        } else {
                            Color.theme.cardBackground
                        }
                    }
                )
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? color : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    CategoryFilterView(categories: [], selectedCategory: .constant(nil))
        .background(Color.black)
}
