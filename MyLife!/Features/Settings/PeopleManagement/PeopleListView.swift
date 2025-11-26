import SwiftUI
import SwiftData

struct PeopleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.name) private var people: [Person]
    @State private var showingAddPerson = false
    @State private var personToEdit: Person?
    
    var body: some View {
        List {
            if people.isEmpty {
                ContentUnavailableView("No People Added", systemImage: "person.2", description: Text("Add important people to tag them in your life events."))
            } else {
                ForEach(people) { person in
                    HStack {
                        Text(person.emoji)
                            .font(.title2)
                        Text(person.name)
                            .font(.body)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        personToEdit = person
                    }
                }
                .onDelete(perform: deletePerson)
            }
        }
        .navigationTitle("Manage People")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingAddPerson = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddPerson) {
            EditPersonView()
        }
        .sheet(item: $personToEdit) { person in
            EditPersonView(personToEdit: person)
        }
    }
    
    private func deletePerson(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(people[index])
            }
        }
    }
}

#Preview {
    PeopleListView()
        .modelContainer(for: Person.self, inMemory: true)
}
