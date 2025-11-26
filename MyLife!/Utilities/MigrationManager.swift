import Foundation
import SwiftData
import SwiftUI

class MigrationManager {
    static let shared = MigrationManager()
    
    @MainActor
    func performMigration(modelContext: ModelContext) {
        // 1. Ensure all default categories exist
        let defaultCategories: [(EventCategory, String, String)] = [
            (.work, "#A2845E", "briefcase.fill"),
            (.education, "#007AFF", "graduationcap.fill"),
            (.living, "#34C759", "house.fill"),
            (.travel, "#5856D6", "airplane"),
            (.event, "#FF9500", "star.fill"),
            (.relationship, "#FF2D55", "heart.fill")
        ]
        
        var categoryMap: [String: Category] = [:]
        
        for (enumCat, colorHex, icon) in defaultCategories {
            let name = enumCat.rawValue
            
            // Check if exists
            let descriptor = FetchDescriptor<Category>(predicate: #Predicate { $0.name == name })
            
            if let existing = try? modelContext.fetch(descriptor).first {
                categoryMap[name] = existing
            } else {
                // Create new
                let newCat = Category(name: name, colorHex: colorHex, iconName: icon, isSystemDefault: true)
                modelContext.insert(newCat)
                categoryMap[name] = newCat
                print("Migration: Created category '\(name)'")
            }
        }
        
        // 2. Link existing events to categories
        do {
            let events = try modelContext.fetch(FetchDescriptor<LifeEvent>())
            var updateCount = 0
            
            for event in events {
                if event.categoryModel == nil {
                    // Find matching category by raw value
                    if let cat = categoryMap[event.categoryRawValue] {
                        event.categoryModel = cat
                        updateCount += 1
                    } else {
                        // Fallback to 'Event' if unknown
                        if let defaultCat = categoryMap[EventCategory.event.rawValue] {
                            event.categoryModel = defaultCat
                            updateCount += 1
                        }
                    }
                }
            }
            
            if updateCount > 0 {
                try modelContext.save()
                print("Migration: Linked \(updateCount) events to categories.")
            }
        } catch {
            print("Migration Error: \(error)")
        }
    }
}
