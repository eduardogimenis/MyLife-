# Design Principles & System

## Design Philosophy
**MyLife!** adopts a modern, clean, and content-focused design philosophy. The interface is designed to be unobtrusive, letting the user's memories (photos and text) take center stage.

### Dark Mode First
The application enforces a **Dark Mode** aesthetic (`.preferredColorScheme(.dark)`), creating a cinematic and premium feel that enhances the visibility of photos and colored category indicators.

## Design System

### Typography
The app uses a custom type scale defined in `DesignSystem/Typography.swift`:
- **Hero:** System Rounded, Bold, 34pt. Used for major headers.
- **Section Header:** System Rounded, Semibold, 22pt. Used for grouping content.
- **Body:** System Default, Regular, 17pt. Standard readability.
- **Caption:** System Default, Medium, 13pt. Used for metadata like dates.

**Rationale:** The use of "Rounded" design for headings adds a friendly and personal touch, fitting for a personal journal app.

### Color Palette
Colors are managed centrally in `DesignSystem/Colors.swift` and `Assets.xcassets`.
- **Background:** Dark, high-contrast background.
- **Cards:** Semi-transparent black (`Color.black.opacity(0.3)`) to provide depth without blocking the background completely.
- **Semantic Colors:**
    - **Work:** Blue
    - **Living:** Green
    - **Travel:** Orange
    - **Event:** Purple
    - **Relationship:** Pink (Fallback)

### Iconography
The app relies heavily on **SF Symbols** for consistency with the iOS ecosystem.
- **Timeline:** `clock.arrow.circlepath`
- **Gallery:** `photo.stack`
- **Search:** `magnifyingglass`
- **Settings:** `gear`
- **Category Icons:** Specific symbols (e.g., `briefcase.fill`, `airplane`) are mapped to categories.

## UX Patterns

### Timeline Visualization
- **Vertical Flow:** The timeline is a vertical list, intuitive for mobile scrolling.
- **Visual Connectors:** A vertical line connects events, symbolizing the continuity of life.
- **Nodes:** Each event is marked by a node on the timeline, color-coded by category.

### Interactions
- **Context Menus:** Long-press interactions on timeline items for quick actions (Edit, Delete).
- **Sheets:** Creation and editing flows use modal sheets to maintain context.
- **Feedback:** Haptic feedback (`UIImpactFeedbackGenerator`) is used for destructive actions (delete) and success states (save).
