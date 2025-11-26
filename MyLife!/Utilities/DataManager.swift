import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct LifeEventCodable: Codable {
    let title: String
    let date: Date
    let isApproximate: Bool
    let categoryRawValue: String
    let notes: String?
    let locationName: String?
    // We don't export photoID or externalLink for now as they are local/complex
}

struct ImportResult {
    var importedCount: Int = 0
    var duplicateCount: Int = 0
    var formatValid: Bool = false
}

class DataManager {
    static let shared = DataManager()
    
    func exportJSON(events: [LifeEvent]) -> String? {
        let codableEvents = events.map { event in
            LifeEventCodable(
                title: event.title,
                date: event.date,
                isApproximate: event.isApproximate,
                categoryRawValue: event.categoryRawValue,
                notes: event.notes,
                locationName: event.locationName
            )
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(codableEvents)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Export error: \(error)")
            return nil
        }
    }
    
    func importJSON(json: String, context: ModelContext) -> ImportResult {
        guard let data = json.data(using: .utf8) else { return ImportResult() }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let importedEvents = try decoder.decode([LifeEventCodable].self, from: data)
            var result = ImportResult(formatValid: true)
            
            for item in importedEvents {
                // Check for duplicates
                if eventExists(title: item.title, date: item.date, context: context) {
                    result.duplicateCount += 1
                    continue
                }
                
                let newEvent = LifeEvent(
                    title: item.title,
                    date: item.date,
                    isApproximate: item.isApproximate,
                    category: EventCategory(rawValue: item.categoryRawValue) ?? .event,
                    notes: item.notes,
                    locationName: item.locationName
                )
                context.insert(newEvent)
                result.importedCount += 1
            }
            return result
        } catch {
            print("Import error: \(error)")
            return ImportResult(formatValid: false)
        }
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
