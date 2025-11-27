# MyLife! iOS App Knowledge Base

## 1. Project Overview
**MyLife!** is a personal timeline and life tracking iOS application built with **SwiftUI** and **SwiftData**. It allows users to document significant life events, categorize them, associate people, and attach photos.

**Tech Stack:**
- **Language:** Swift 5+
- **UI Framework:** SwiftUI
- **Database:** SwiftData
- **Minimum iOS Version:** iOS 17.0+ (implied by SwiftData usage)

## 2. Architecture
The project follows a feature-based architecture with a clear separation of concerns.

### Directory Structure
- **`MyLife!`**: Root source directory.
    - **`App`**: `MyLife_App.swift` (Entry point), `ContentView.swift`.
    - **`Features`**: Contains feature-specific views and logic (Timeline, Gallery, Search, Settings, AddEvent).
    - **`Models`**: SwiftData models (`LifeEvent`, `Category`, `Person`).
    - **`Utilities`**: Helper classes (`MigrationManager`, `PhotoManager`, `DataManager`).
    - **`DesignSystem`**: Reusable UI components and styles.
    - **`Assets.xcassets`**: Images and Color sets.

### Data Persistence
The app uses **SwiftData** for local persistence. The `ModelContainer` is initialized in `MyLife_App.swift` with `LifeEvent` and `Category` schemas.

## 3. Data Models

### `LifeEvent`
The core entity representing a specific event in the user's life.
- **Properties:**
    - `title`: String
    - `date`: Date
    - `isApproximate`: Bool (flag for fuzzy dates)
    - `categoryRawValue`: String (Legacy/Backup category identifier)
    - `notes`: String?
    - `locationName`: String?
    - `photoID`: String? (Filename of the image stored in Documents)
    - `externalLink`: URL?
- **Relationships:**
    - `categoryModel`: Optional `Category`
    - `people`: Optional List of `Person`
- **Computed Properties:**
    - `category`: Returns an `EventCategory` enum based on `categoryRawValue`.

### `Category`
Represents a category for events (e.g., Work, Education, Travel).
- **Properties:**
    - `name`: String (Unique)
    - `colorHex`: String
    - `iconName`: String (SF Symbol name)
    - `isSystemDefault`: Bool

### `Person`
Represents a person that can be tagged in events.
- **Properties:**
    - `name`: String
    - `relationship`: String? (e.g., "Friend", "Family")

## 4. Key Features

### Timeline (`Features/Timeline`)
- **View:** `TimelineView.swift`
- **Functionality:**
    - Displays `LifeEvent`s in reverse chronological order.
    - Uses `TimelineNode` for visual timeline representation.
    - Supports deleting events via context menu.
    - "Load Mock Data" functionality for testing.

### Add/Edit Event (`Features/AddEvent`)
- **View:** `AddEventView.swift`
- **Functionality:**
    - Form to create or edit an event.
    - **Photo Picker:** Uses `PhotosPicker` to select images. Images are saved to the local Documents directory via `PhotoManager`.
    - **People Tagging:** Allows selecting people from the `Person` model.
    - **Category Selection:** Dynamic picker based on available `Category` models.

### Navigation (`Features/MainTab`)
- **View:** `MainTabView.swift`
- **Tabs:**
    1.  **Timeline**
    2.  **Gallery**
    3.  **Search**
    4.  **Settings**
- **Onboarding:** Shows `WelcomeView` on first launch.

### Settings (`Features/Settings`)
- **Functionality:**
    - Manage Categories (Create/Edit/Delete).
    - Manage People.
    - App preferences.

## 5. Utilities & Services

### `MigrationManager`
- **Location:** `Utilities/MigrationManager.swift`
- **Purpose:** Handles initial data setup and schema migrations.
- **Key Actions:**
    - Creates default categories (Work, Education, Living, etc.) if they don't exist.
    - Links legacy `LifeEvent`s to `Category` models based on raw values.

### `PhotoManager`
- **Location:** `Utilities/PhotoManager.swift`
- **Purpose:** Manages image storage.
- **Mechanism:** Saves images as JPEGs in the app's Documents directory using UUID filenames. Stores the filename in `LifeEvent.photoID`.

### `MockData`
- **Location:** `Utilities/MockData.swift`
- **Purpose:** Generates sample data for testing and previews.

## 6. Design System
- **Theme:** The app enforces **Dark Mode** (`.preferredColorScheme(.dark)` in `ContentView`).
- **Colors:** Custom colors are defined in `Assets.xcassets` and accessed via `Color.theme` extension.
- **Icons:** Uses SF Symbols throughout the app.
