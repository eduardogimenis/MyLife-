import Foundation
import SwiftData

class GenericCSVParser {
    static let shared = GenericCSVParser()
    
    func parse(csvString: String, mapping: [String: String], context: ModelContext) -> ImportResult {
        let rows = CSVHelper.parse(csvString: csvString)
        var result = ImportResult(formatValid: true)
        
        guard let titleKey = mapping["title"], !titleKey.isEmpty,
              let dateKey = mapping["date"], !dateKey.isEmpty else {
            return ImportResult(formatValid: false)
        }
        
        let notesKey = mapping["notes"]
        
        // Date formatters to try
        let dateFormatters: [DateFormatter] = [
            { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f }(),
            { let f = DateFormatter(); f.dateFormat = "MM/dd/yyyy"; return f }(),
            { let f = DateFormatter(); f.dateFormat = "dd/MM/yyyy"; return f }(),
            { let f = DateFormatter(); f.dateFormat = "yyyy"; return f }(),
            { let f = DateFormatter(); f.dateStyle = .medium; return f }(),
            { let f = DateFormatter(); f.dateStyle = .short; return f }()
        ]
        
        let isoFormatter = ISO8601DateFormatter()
        
        for row in rows {
            guard let title = row[titleKey], !title.isEmpty,
                  let dateString = row[dateKey], !dateString.isEmpty else {
                continue
            }
            
            var date: Date?
            
            // Try ISO first
            if let d = isoFormatter.date(from: dateString) {
                date = d
            } else {
                // Try other formats
                for formatter in dateFormatters {
                    if let d = formatter.date(from: dateString) {
                        date = d
                        break
                    }
                }
            }
            
            guard let validDate = date else { continue }
            
            let notes = (notesKey != nil && !notesKey!.isEmpty) ? row[notesKey!] : nil
            
            // Check for duplicates
            if eventExists(title: title, date: validDate, context: context) {
                result.duplicateCount += 1
                continue
            }
            
            let newEvent = LifeEvent(
                title: title,
                date: validDate,
                isApproximate: false, // Assume exact unless we add mapping for this
                category: .event, // Default category
                notes: notes,
                locationName: nil
            )
            
            context.insert(newEvent)
            result.importedCount += 1
        }
        
        return result
    }
    
    private func eventExists(title: String, date: Date, context: ModelContext) -> Bool {
        var descriptor = FetchDescriptor<LifeEvent>(
            predicate: #Predicate { $0.title == title && $0.date == date }
        )
        descriptor.fetchLimit = 1
        
        do {
            let count = try context.fetchCount(descriptor)
            return count > 0
        } catch {
            return false
        }
    }
}
