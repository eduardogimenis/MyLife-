import SwiftUI
import SwiftData

struct EditCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var color: Color = .blue
    @State private var iconName: String = "star.fill"
    
    var categoryToEdit: Category?
    
    private let availableIcons = [
        // Basics
        "briefcase.fill", "graduationcap.fill", "house.fill", "airplane", "star.fill", "heart.fill",
        "person.fill", "cart.fill", "gamecontroller.fill", "tv.fill", "music.note", "book.fill",
        "sportscourt.fill", "car.fill", "leaf.fill", "flame.fill", "bolt.fill", "cross.case.fill",
        
        // Pets & Animals
        "pawprint.fill", "cat.fill", "dog.fill", "fish.fill", "bird.fill", "tortoise.fill", 
        "hare.fill", "ant.fill", "ladybug.fill",
        
        // Nature & Weather
        "tree.fill", "camera.macro", "drop.fill", "sun.max.fill", "moon.fill", "cloud.rain.fill",
        "snowflake", "mountain.2.fill",
        
        // Activities & Hobbies
        "figure.run", "figure.walk", "bicycle", "sailboat.fill", "theatermasks.fill", 
        "paintpalette.fill", "camera.fill", "hammer.fill",
        
        // Food & Drink
        "fork.knife", "cup.and.saucer.fill", "wineglass.fill", "birthday.cake.fill",
        
        // Objects & Celebration
        "gift.fill", "balloon.fill", "party.popper.fill", "lightbulb.fill", "bell.fill", 
        "tag.fill", "creditcard.fill", "bag.fill"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Name", text: $name)
                    ColorPicker("Color", selection: $color)
                }
                
                Section(header: Text("Icon")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(iconName == icon ? .white : .primary)
                                .frame(width: 44, height: 44)
                                .background(iconName == icon ? Color.theme.accent : Color.clear)
                                .cornerRadius(8)
                                .onTapGesture {
                                    iconName = icon
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(categoryToEdit == nil ? "New Category" : "Edit Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCategory() }
                        .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let cat = categoryToEdit {
                    name = cat.name
                    color = cat.color
                    iconName = cat.iconName
                }
            }
        }
    }
    
    private func saveCategory() {
        if let cat = categoryToEdit {
            cat.name = name
            cat.colorHex = color.toHex() ?? "#000000"
            cat.iconName = iconName
        } else {
            let newCat = Category(
                name: name,
                colorHex: color.toHex() ?? "#000000",
                iconName: iconName
            )
            modelContext.insert(newCat)
        }
        dismiss()
    }
}
