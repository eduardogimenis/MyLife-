import Foundation
import SwiftData

class LinkedInParser {
    static let shared = LinkedInParser()
    
    func parsePositions(csvString: String, context: ModelContext) -> ImportResult {
        let rows = CSVHelper.parse(csvString: csvString)
        // Basic validation: check if required headers exist
        guard let firstRow = rows.first, firstRow.keys.contains("Title") else {
            return ImportResult(formatValid: false)
        }
        
        var result = ImportResult(formatValid: true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy" // LinkedIn format: "Jan 2020"
        
        for row in rows {
            // Required fields
            guard let title = row["Title"],
                  let company = row["Company Name"],
                  let startDateString = row["Started On"],
                  let startDate = dateFormatter.date(from: startDateString) else {
                continue
            }
            
            let description = row["Description"]
            let location = row["Location"]
            let eventTitle = "\(title) at \(company)"
            
            // Parse End Date
            var endDate: Date? = nil
            if let endDateString = row["Finished On"], !endDateString.isEmpty {
                endDate = dateFormatter.date(from: endDateString)
            }
            
            // Check for duplicates
            if eventExists(title: eventTitle, date: startDate, context: context) {
                result.duplicateCount += 1
                continue
            }
            
            let newEvent = LifeEvent(
                title: eventTitle,
                date: startDate,
                endDate: endDate,
                isApproximate: false,
                category: .work,
                notes: description,
                locationName: location
            )
            
            context.insert(newEvent)
            result.importedCount += 1
        }
        
        return result
    }
    
    func parseEducation(csvString: String, context: ModelContext) -> ImportResult {
        let rows = CSVHelper.parse(csvString: csvString)
        // Basic validation
        guard let firstRow = rows.first, firstRow.keys.contains("School Name") else {
            return ImportResult(formatValid: false)
        }
        
        var result = ImportResult(formatValid: true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy" // LinkedIn Education often just has year
        
        for row in rows {
            guard let school = row["School Name"],
                  let startDateString = row["Start Date"],
                  let startDate = dateFormatter.date(from: startDateString) else {
                continue
            }
            
            let degree = row["Degree Name"] ?? ""
            let notes = row["Notes"]
            
            // Parse End Date
            var endDate: Date? = nil
            if let endDateString = row["End Date"], !endDateString.isEmpty {
                endDate = dateFormatter.date(from: endDateString)
            }
            
            let title = degree.isEmpty ? school : "\(degree) at \(school)"
            
            // Check for duplicates
            if eventExists(title: title, date: startDate, context: context) {
                result.duplicateCount += 1
                continue
            }
            
            let newEvent = LifeEvent(
                title: title,
                date: startDate,
                endDate: endDate,
                isApproximate: true, // Year only is usually approximate
                category: .education,
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
