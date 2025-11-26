import Foundation

class CSVHelper {
    static func parse(csvString: String) -> [[String: String]] {
        var result: [[String: String]] = []
        
        let rows = csvString.components(separatedBy: "\n")
        guard let headerRow = rows.first else { return [] }
        
        let headers = parseRow(headerRow)
        
        for i in 1..<rows.count {
            let rowString = rows[i]
            if rowString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }
            
            let values = parseRow(rowString)
            var dict: [String: String] = [:]
            
            for (index, header) in headers.enumerated() {
                if index < values.count {
                    dict[header] = values[index]
                }
            }
            
            if !dict.isEmpty {
                result.append(dict)
            }
        }
        
        return result
    }
    
    private static func parseRow(_ row: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var insideQuotes = false
        
        for char in row {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                result.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        result.append(currentField)
        
        // Clean up quotes
        return result.map { field in
            var cleaned = field.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleaned.hasPrefix("\"") && cleaned.hasSuffix("\"") {
                cleaned.removeFirst()
                cleaned.removeLast()
            }
            return cleaned.replacingOccurrences(of: "\"\"", with: "\"")
        }
    }
}
