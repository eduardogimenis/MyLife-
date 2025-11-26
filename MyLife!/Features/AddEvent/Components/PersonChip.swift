import SwiftUI

struct PersonChip: View {
    let person: Person
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(person.emoji)
                Text(person.name)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.theme.accent : Color.theme.cardBackground)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.theme.accent : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
