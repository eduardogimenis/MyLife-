import SwiftUI

struct ColumnMappingView: View {
    let csvHeaders: [String]
    let onComplete: ([String: String]) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var titleColumn: String = ""
    @State private var dateColumn: String = ""
    @State private var notesColumn: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Map Columns")) {
                    Text("Select which column in your CSV corresponds to each field.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Title (Required)", selection: $titleColumn) {
                        Text("Select Column").tag("")
                        ForEach(csvHeaders, id: \.self) { header in
                            Text(header).tag(header)
                        }
                    }
                    
                    Picker("Date (Required)", selection: $dateColumn) {
                        Text("Select Column").tag("")
                        ForEach(csvHeaders, id: \.self) { header in
                            Text(header).tag(header)
                        }
                    }
                    
                    Picker("Notes (Optional)", selection: $notesColumn) {
                        Text("None").tag("")
                        ForEach(csvHeaders, id: \.self) { header in
                            Text(header).tag(header)
                        }
                    }
                }
            }
            .navigationTitle("Import Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        let mapping = [
                            "title": titleColumn,
                            "date": dateColumn,
                            "notes": notesColumn
                        ]
                        onComplete(mapping)
                        dismiss()
                    }
                    .disabled(titleColumn.isEmpty || dateColumn.isEmpty)
                }
            }
        }
        .onAppear {
            autoDetectColumns()
        }
    }
    
    private func autoDetectColumns() {
        for header in csvHeaders {
            let lower = header.lowercased()
            
            if titleColumn.isEmpty && (lower.contains("title") || lower.contains("event") || lower.contains("name")) {
                titleColumn = header
            }
            
            if dateColumn.isEmpty && (lower.contains("date") || lower.contains("time") || lower.contains("start")) {
                dateColumn = header
            }
            
            if notesColumn.isEmpty && (lower.contains("note") || lower.contains("description") || lower.contains("details") || lower.contains("caption")) {
                notesColumn = header
            }
        }
    }
}
