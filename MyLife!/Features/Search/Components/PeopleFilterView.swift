import SwiftUI

struct PeopleFilterView: View {
    let people: [Person]
    @Binding var selectedPerson: Person?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "All" Chip
                FilterChip(
                    title: "All People",
                    isSelected: selectedPerson == nil,
                    color: .gray
                ) {
                    withAnimation {
                        selectedPerson = nil
                    }
                }
                
                // Person Chips
                ForEach(people) { person in
                    PersonFilterChip(
                        person: person,
                        isSelected: selectedPerson == person
                    ) {
                        withAnimation {
                            if selectedPerson == person {
                                selectedPerson = nil
                            } else {
                                selectedPerson = person
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

struct PersonFilterChip: View {
    let person: Person
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(person.emoji)
                Text(person.name)
            }
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        Color.theme.accent
                    } else {
                        Color.theme.cardBackground
                    }
                }
            )
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.theme.accent : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    PeopleFilterView(people: [], selectedPerson: .constant(nil))
        .background(Color.black)
}
