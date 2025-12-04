import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var tourManager: TourManager
    @Query(sort: \Category.name) private var categories: [Category]
    @State private var showingAddCategory = false
    @State private var categoryToEdit: Category?
    
    var body: some View {
        ZStack {
            List {
                ForEach(categories) { category in
                    HStack {
                        Image(systemName: category.iconName)
                            .foregroundColor(category.color)
                            .frame(width: 30)
                        
                        Text(category.name)
                            .font(.headline)
                            .textContrast()
                        
                        Spacer()
                        
                        if category.isSystemDefault {
                            Text("Default")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                                .textContrast()
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        categoryToEdit = category
                    }
                }
                .onDelete(perform: deleteCategory)
            }
            
            // Tutorial Overlay
            if tourManager.currentStep == .insideCategories {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture { }
                
                VStack(spacing: 20) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.theme.accent)
                    
                    Text("Create Custom Categories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Tap the + button in the top right to add your own categories like 'Hobbies', 'Travel', or 'Projects'.\n\nYou can choose a custom icon and color for each.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Button("Back to Settings") {
                        withAnimation {
                            tourManager.currentStep = .settingsHighlightPeople
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
            if tourManager.currentStep == .settingsHighlightCategories {
                withAnimation {
                    tourManager.currentStep = .insideCategories
                }
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingAddCategory = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            EditCategoryView()
        }
        .sheet(item: $categoryToEdit) { category in
            EditCategoryView(categoryToEdit: category)
        }
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            if !category.isSystemDefault {
                modelContext.delete(category)
            }
        }
    }
}

