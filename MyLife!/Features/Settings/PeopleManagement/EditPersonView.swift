import SwiftUI
import SwiftData

struct EditPersonView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var emoji: String = "👤"
    
    var personToEdit: Person?
    
    init(personToEdit: Person? = nil) {
        self.personToEdit = personToEdit
        _name = State(initialValue: personToEdit?.name ?? "")
        _emoji = State(initialValue: personToEdit?.emoji ?? "👤")
    }
    
    private let emojiOptions = [
        // Faces
        "👤", "😀", "😂", "😍", "😎", "🥳", "😴", "😇", "🤔", "🤫", "🤯", "🤠",
        "👨", "👩", "🧒", "👴", "👵", "👶", "👱‍♂️", "👱‍♀️", "🧔",
        
        // Roles & Professions
        "👮", "👩‍⚕️", "👨‍💻", "👩‍🎨", "🦸", "🦹", "🧙‍♂️", "🧚‍♀️", "🧛‍♂️", "🧜‍♀️",
        "👷", "👩‍🏫", "👨‍🍳", "👩‍🌾", "👨‍🔧", "👩‍🔬", "👨‍🚀", "👩‍🚒",
        
        // Relationships & Love
        "❤️", "💖", "💍", "👯", "👨‍👩‍👧", "🤝", "👩‍❤️‍👨", "👨‍❤️‍👨", "👩‍❤️‍👩",
        
        // Fantasy & Fun
        "🌟", "👻", "👽", "🤖", "👾", "🤡", "💩", "🐶", "🐱"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Select Icon")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 10) {
                        ForEach(emojiOptions, id: \.self) { option in
                            Text(option)
                                .font(.title)
                                .frame(width: 44, height: 44)
                                .background(emoji == option ? Color.theme.accent.opacity(0.3) : Color.clear)
                                .cornerRadius(8)
                                .onTapGesture {
                                    emoji = option
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Custom Emoji")) {
                    HStack {
                        Text("Type your own:")
                        Spacer()
                        TextField("Emoji", text: $emoji)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 50)
                            .onChange(of: emoji) { oldValue, newValue in
                                if newValue.count > 1 {
                                    emoji = String(newValue.prefix(1))
                                }
                            }
                    }
                }
            }
            .navigationTitle(personToEdit == nil ? "Add Person" : "Edit Person")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePerson()
                    }
                    .disabled(name.isEmpty || emoji.isEmpty)
                }
            }
        }
    }
    
    private func savePerson() {
        if let person = personToEdit {
            person.name = name
            person.emoji = emoji
        } else {
            let newPerson = Person(name: name, emoji: emoji)
            modelContext.insert(newPerson)
        }
        dismiss()
    }
}

#Preview {
    EditPersonView()
}
