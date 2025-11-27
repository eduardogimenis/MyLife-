# Implementation Details & Deep Dive Findings

This document captures specific implementation details discovered during the deep dive analysis of the codebase. It serves as a reference for understanding the "how" of specific features and components.

## 1. Shared UI Components

### `AsyncPhotoView`
- **Location:** Defined in `Features/Timeline/Components/EventCard.swift` (Not a standalone file).
- **Purpose:** Asynchronously loads and displays images from the Documents directory.
- **Implementation:**
    - Uses `DispatchQueue.global` to load the `UIImage` from disk to avoid blocking the main thread.
    - Displays a placeholder `ProgressView` while loading.
    - Used in `EventCard`, `GalleryView`, and `EventDetailView`.

### `TimelineNode`
- **Location:** `Features/Timeline/Components/TimelineNode.swift`
- **Purpose:** Renders the circular node on the timeline.
- **Logic:**
    - Displays a solid circle colored by the category.
    - If `isApproximate` is true, adds a glowing/blurred outer ring to visually indicate uncertainty.
    - Handles fallback colors if the `Category` model is missing (uses `EventCategory` enum).

### `EventCard`
- **Location:** `Features/Timeline/Components/EventCard.swift`
- **Purpose:** The main list item view for events.
- **Features:**
    - Displays Title, Date, Location, and Photo Thumbnail.
    - Shows Category Icon and up to 3 Person Chips (with a "+N" overflow indicator).
    - Uses a custom `.glassCard()` modifier (likely in `DesignSystem`, though not explicitly analyzed, inferred from usage).

### `PersonChip`
- **Location:** `Features/AddEvent/Components/PersonChip.swift`
- **Purpose:** A selectable chip for people.
- **Style:**
    - Selected: Accent color background, white text.
    - Unselected: Card background, primary text.

### `CategoryFilterView`
- **Location:** `Features/Search/Components/CategoryFilterView.swift`
- **Purpose:** Horizontal scrollable list of category chips.
- **Logic:**
    - Supports "All" (nil selection).
    - Tapping a selected category deselects it (returns to "All").

## 2. Feature Implementations

### Settings & Data Management
- **Location:** `Features/Settings/SettingsView.swift`
- **Import Logic:**
    - **LinkedIn:** Uses `LinkedInParser` to parse `Positions.csv` and `Education.csv`.
    - **Instagram:** Uses `InstagramParser` to parse `media.json`.
    - **Generic CSV:** Uses `GenericCSVParser` with a column mapping UI (`ColumnMappingView`).
    - **Generic JSON:** Direct mapping to `LifeEventCodable`.
- **Security:** Uses `startAccessingSecurityScopedResource()` when handling file imports to ensure permission.

### Search
- **Location:** `Features/Search/SearchView.swift`
- **Filtering:**
    - Performed in-memory on the `events` array (fetched via `@Query`).
    - Matches against `title`, `notes`, and `locationName`.
    - Case-insensitive.
    - Combined with Category filter.

### Gallery
- **Location:** `Features/Gallery/GalleryView.swift`
- **Layout:** `LazyVGrid` with adaptive columns (min width 150px).
- **Query:** Filters for events where `photoID != nil`.
