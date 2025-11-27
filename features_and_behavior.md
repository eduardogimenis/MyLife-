# Features & Expected Behavior

## 1. Timeline Management

### View Timeline
- **Behavior:** On launch, the user sees a list of life events sorted by date (newest first).
- **Empty State:** If no events exist, a "No Events" placeholder is shown with options to "Add Event" or "Load Mock Data".
- **Visuals:** Each event shows a title, date, category icon/color, and a preview of the note or photo if available. A vertical line connects the events.

### Add Event
- **Trigger:** Tap the "+" button in the top-right corner.
- **Fields:**
    - **Title:** Required text.
    - **Date:** Date picker.
    - **Approximate Date:** Toggle. If on, the exact time might be hidden in the UI (implementation detail).
    - **Category:** Picker showing available categories with icons.
    - **Location:** Text field.
    - **People:** Horizontal scrollable list of chips to select people.
    - **Photo:** Photo picker to select an image from the library.
    - **Notes:** Multi-line text editor.
- **Validation:** "Save" button is disabled if the Title is empty.
- **Outcome:** Saving closes the sheet and updates the timeline immediately.

### Edit Event
- **Trigger:** Tap an event card or use the "Edit" context menu action.
- **Behavior:** Opens the same form as "Add Event" pre-filled with existing data.
- **Photo Handling:** Existing photo is shown. Selecting a new photo replaces the old one.

### Delete Event
- **Trigger:** Long-press an event and select "Delete".
- **Feedback:** Haptic impact occurs upon deletion. The event is removed from the list immediately.

## 2. Category Management

### Default Categories
The app ships with a set of immutable default categories:
- Work
- Education
- Living
- Travel
- Event
- Relationship

### Custom Categories (Implied/Extensible)
- While the current `MigrationManager` sets up defaults, the data model supports creating new `Category` entities.
- **Behavior:** Users can select these categories when creating events.

## 3. People Management
- **Functionality:** Users can create `Person` entities (likely in Settings, though specific view code wasn't deeply analyzed, the model exists).
- **Usage:** These people appear as selectable chips in the "Add Event" screen.

## 4. Data Persistence & Migration
- **Storage:** All data is stored in a local SQLite database via SwiftData.
- **Migration:** On app launch, `MigrationManager` checks for missing default categories and creates them. It also attempts to link legacy events (using string-based categories) to the new `Category` models.

## 5. Import/Export
- **Export:** Users can export their timeline to a JSON string (via `DataManager`).
- **Import:** Users can import a JSON string. The system checks for duplicates based on Title and Date to prevent data corruption.

## 6. Search
- **Functionality:** A dedicated Search tab allows users to find events.
- **Scope:** (Inferred) Likely searches titles and notes.

## 7. Gallery
- **Functionality:** A dedicated Gallery tab to view all photos attached to events in a grid layout.
