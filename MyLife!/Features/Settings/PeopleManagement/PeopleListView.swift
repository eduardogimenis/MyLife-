import SwiftUI
import SwiftData

struct PeopleListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var tourManager: TourManager
    @Query(sort: \Person.name) private var people: [Person]
    @State private var showingAddPerson = false
    @State private var personToEdit: Person?
    
    var body: some View {
        ZStack {
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
            
            // Tutorial Overlay
            if tourManager.currentStep == .insidePeople {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture { }
                
                VStack(spacing: 20) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.theme.accent)
                    
                    Text("Add Important People")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Keep track of family, friends, and colleagues.\n\nLink them to events to see your history together.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Button("Finish Tour") {
                        withAnimation {
                            tourManager.endTour()
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.theme.accent)
                    .padding(.top, 10)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(radius: 10)
                )
                .padding(40)
                .transition(.scale.combined(with: .opacity))
                .zIndex(100)
            }
        }
        .onAppear {
            if tourManager.currentStep == .settingsHighlightPeople {
                withAnimation {
                    tourManager.currentStep = .insidePeople
                }
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
