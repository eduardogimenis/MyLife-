import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) private var categories: [Category]
    @State private var showingAddCategory = false
    @State private var categoryToEdit: Category?
    
    var body: some View {
        List {
            ForEach(categories) { category in
                HStack {
                    Image(systemName: category.iconName)
                        .foregroundColor(category.color)
                        .frame(width: 30)
                    
                    Text(category.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    if category.isSystemDefault {
                        Text("Default")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    categoryToEdit = category
                }
            }
            .onDelete(perform: deleteCategory)
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
