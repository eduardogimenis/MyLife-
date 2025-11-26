import Foundation
import SwiftData

struct InstagramMediaItem: Codable {
    let caption: String?
    let taken_at: String? // ISO 8601 or timestamp
    let path: String? // Path to local file in export
}

struct InstagramExport: Codable {
    let photos: [InstagramMediaItem]?
    let videos: [InstagramMediaItem]?
    // Structure varies, sometimes it's just a list
}

class InstagramParser {
    static let shared = InstagramParser()
    
    func parseMedia(jsonString: String, context: ModelContext) -> ImportResult {
        guard let data = jsonString.data(using: .utf8) else { return ImportResult(formatValid: false) }
        var result = ImportResult(formatValid: true)
        
        let decoder = JSONDecoder()
        // Instagram dates can be tricky. Let's try ISO8601 first.
        
        // Helper to parse date
        func parseDate(_ dateString: String) -> Date? {
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            // Fallback for timestamp if needed, though usually it's ISO string in recent exports
            return nil
        }
        
        do {
            // Try parsing as a dictionary first (standard export)
            if let export = try? decoder.decode([String: [InstagramMediaItem]].self, from: data) {
                 // Usually keys are "photos", "stories", "videos"
                for (_, items) in export {
                    let subResult = processItems(items, context: context)
                    result.importedCount += subResult.importedCount
                    result.duplicateCount += subResult.duplicateCount
                }
            } else if let items = try? decoder.decode([InstagramMediaItem].self, from: data) {
                // Flat list fallback
                let subResult = processItems(items, context: context)
                result.importedCount += subResult.importedCount
                result.duplicateCount += subResult.duplicateCount
            } else {
                return ImportResult(formatValid: false)
            }
        }
        
        return result
    }
    
    private func processItems(_ items: [InstagramMediaItem], context: ModelContext) -> ImportResult {
        var result = ImportResult(formatValid: true)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        for item in items {
            guard let dateString = item.taken_at,
                  let date = isoFormatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString) else {
                continue
            }
            
            let caption = item.caption ?? "Instagram Memory"
            let title = "Instagram Post"
            
            // Check for duplicates
            if eventExists(title: title, date: date, notes: caption, context: context) {
                result.duplicateCount += 1
                continue
            }
            
            let newEvent = LifeEvent(
                title: title,
                date: date,
                isApproximate: false,
                category: .living, // Default to Living
                notes: caption,
                locationName: nil
            )
            
            context.insert(newEvent)
            result.importedCount += 1
        }
        return result
    }
    
    private func eventExists(title: String, date: Date, notes: String, context: ModelContext) -> Bool {
        // For Instagram, since title is generic, we should also check notes (caption)
        var descriptor = FetchDescriptor<LifeEvent>(
            predicate: #Predicate { $0.title == title && $0.date == date && $0.notes == notes }
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
