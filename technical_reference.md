# Technical Reference & Project Analysis

## Project Structure
The project is a standard SwiftUI application structure.

```
MyLife!/
├── App/
│   ├── MyLife_App.swift       # App Entry Point, ModelContainer setup
│   └── ContentView.swift      # Root View, TabView wrapper
├── Features/
│   ├── Timeline/              # Timeline Logic
│   ├── AddEvent/              # Event Creation/Editing
│   ├── MainTab/               # Navigation Logic
│   ├── Search/                # Search Feature
│   ├── Settings/              # App Settings
│   └── Gallery/               # Photo Gallery
├── Models/
│   ├── LifeEvent.swift        # Core Data Model
│   ├── Category.swift         # Category Model
│   └── Person.swift           # Person Model
├── Utilities/
│   ├── MigrationManager.swift # Data Migration Logic
│   ├── PhotoManager.swift     # File System Image Handling
│   ├── DataManager.swift      # JSON Import/Export
│   ├── CSVHelper.swift        # CSV Parsing (Unused/Legacy?)
│   └── MockData.swift         # Sample Data Generator
├── DesignSystem/
│   ├── Colors.swift           # Color Theme Definitions
│   └── Typography.swift       # Font Definitions
└── Assets.xcassets            # Image and Color Assets
```

## Data Models (SwiftData)

### `LifeEvent`
- **Annotations:** `@Model`
- **Key Fields:** `title`, `date`, `photoID` (String), `categoryModel` (Relationship).
- **Notes:** `photoID` stores the filename only. The full path is reconstructed at runtime using `PhotoManager`.

### `Category`
- **Annotations:** `@Model`
- **Key Fields:** `name` (Unique), `colorHex`, `iconName`.
- **Defaults:** System defaults are flagged with `isSystemDefault: true`.

## Key Utilities

### PhotoManager
- **Storage Location:** App's `Documents` directory.
- **Naming Convention:** `UUID().uuidString + ".jpg"`.
- **Compression:** JPEG, 0.8 quality.
- **Error Handling:** Basic print statements on failure.

### DataManager
- **Format:** JSON.
- **Duplicate Detection:** Checks for existing events with the exact same `title` and `date`.
- **Date Format:** ISO8601.

### MigrationManager
- **Trigger:** Runs `.onAppear` in `ContentView`.
- **Logic:**
    1.  Checks if default categories exist; creates them if missing.
    2.  Iterates through all events. If `categoryModel` is nil, attempts to find a `Category` matching `categoryRawValue` and links it.

## Dependencies
- **SwiftUI:** UI Framework.
- **SwiftData:** Database.
- **PhotosUI:** Image picking.
- **UniformTypeIdentifiers:** File types for import/export.

## Known Technical Details
- **Dark Mode Enforcement:** The app hardcodes `.preferredColorScheme(.dark)` in `ContentView`.
- **CSV Support:** `CSVHelper.swift` exists but appears to be unused in the main flows analyzed (Import/Export uses JSON).
- **Mock Data:** `MockData.swift` contains a static method `generateSampleEvents()` used by the "Load Mock Data" button in `TimelineView`.
