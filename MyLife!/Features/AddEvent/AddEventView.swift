import SwiftUI
import SwiftData
import PhotosUI

struct AddEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \Person.name) private var allPeople: [Person]
    
    @State private var title = ""
    @State private var date = Date()
    @State private var isApproximate = false
    @State private var selectedCategory: Category?
    @State private var locationName = ""
    @State private var notes = ""
    @State private var selectedPeople: Set<Person> = []
    
    // Photo Picker State
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedPhotoID: String?
    @State private var selectedImage: UIImage?
    
    var eventToEdit: LifeEvent?
    
    init(eventToEdit: LifeEvent? = nil) {
        self.eventToEdit = eventToEdit
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    Toggle("Approximate Date", isOn: $isApproximate)
                        .tint(Color.theme.accent)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories) { cat in
                            HStack {
                                Image(systemName: cat.iconName)
                                    .foregroundColor(cat.color)
                                Text(cat.name)
                            }
                            .tag(cat as Category?)
                        }
                    }
                    
                    TextField("Location", text: $locationName)
                }
                
                if !allPeople.isEmpty {
                    Section(header: Text("People")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(allPeople) { person in
                                    PersonChip(
                                        person: person,
                                        isSelected: selectedPeople.contains(person)
                                    ) {
                                        if selectedPeople.contains(person) {
                                            selectedPeople.remove(person)
                                        } else {
                                            selectedPeople.insert(person)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section(header: Text("Media")) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .cornerRadius(12)
                                .clipped()
                        } else {
                            HStack {
                                Image(systemName: "photo")
                                Text("Select Photo")
                            }
                        }
                    }
                    .onChange(of: selectedItem) { oldValue, newItem in
                        Task {
                            if let newItem {
                                // Get the local identifier
                                if let assetId = newItem.itemIdentifier {
                                    print("DEBUG: Selected Photo ID: \(assetId)")
                                    selectedPhotoID = assetId
                                } else {
                                    print("DEBUG: No itemIdentifier found for selected item.")
                                }
                                
                                // Load the image for preview
                                if let data = try? await newItem.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    selectedImage = image
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                if eventToEdit != nil {
                    Section {
                        Button(role: .destructive) {
                            deleteEvent()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Event")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(eventToEdit == nil ? "Add Event" : "Edit Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .onAppear {
            print("DEBUG: AddEventView appeared. eventToEdit is \(eventToEdit == nil ? "nil" : "present")")
            if let event = eventToEdit {
                title = event.title
                date = event.date
                isApproximate = event.isApproximate
                selectedCategory = event.categoryModel
                locationName = event.locationName ?? ""
                notes = event.notes ?? ""
                if let people = event.people {
                    selectedPeople = Set(people)
                }
                
                if let photoID = event.photoID {
                    PhotoManager.shared.fetchImage(for: photoID) { image in
                        self.selectedImage = image
                    }
                }
            } else {
                // Default to first category if available
                if selectedCategory == nil, let first = categories.first {
                    selectedCategory = first
                }
            }
        }
    }
    
    private func saveEvent() {
        // Save image to disk if selected
        var savedPhotoID: String?
        if let selectedImage {
            savedPhotoID = PhotoManager.shared.saveImage(selectedImage)
        } else if let event = eventToEdit {
            // Keep existing photo if not changed
            savedPhotoID = event.photoID
        }
        
        if let event = eventToEdit {
            // Update existing event
            event.title = title
            event.date = date
            event.isApproximate = isApproximate
            event.categoryModel = selectedCategory
            // Keep raw value in sync for now, or just ignore it
            if let cat = selectedCategory {
                event.categoryRawValue = cat.name
            }
            event.notes = notes.isEmpty ? nil : notes
            event.locationName = locationName.isEmpty ? nil : locationName
            event.people = Array(selectedPeople)
            if let newPhotoID = savedPhotoID {
                event.photoID = newPhotoID
            }
        } else {
            // Create new event
            let newEvent = LifeEvent(
                title: title,
                date: date,
                isApproximate: isApproximate,
                category: .event, // Placeholder
                notes: notes.isEmpty ? nil : notes,
                locationName: locationName.isEmpty ? nil : locationName,
                photoID: savedPhotoID,
                categoryModel: selectedCategory,
                people: Array(selectedPeople)
            )
            // Sync raw value
            if let cat = selectedCategory {
                newEvent.categoryRawValue = cat.name
            }
            modelContext.insert(newEvent)
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
    
    private func deleteEvent() {
        if let event = eventToEdit {
            modelContext.delete(event)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            dismiss()
        }
    }
}

#Preview {
    AddEventView()
        .modelContainer(for: LifeEvent.self, inMemory: true)
}
