# Brainstorming: Contextual App Tour

## Goal
Replace the modal `WelcomeView` with an interactive tour that navigates the user through the actual app tabs, explaining each one in context without blocking the view.

## Proposed Flow

### 1. Initial State
- App launches on the **Timeline** tab.
- Instead of a full-screen sheet, a **Tour Card** appears (e.g., at the bottom or center).

### 2. Step 1: Timeline
- **Action:** App automatically selects Tab 1 (Timeline).
- **Overlay:** "This is your **Timeline**. Your life events will appear here in a continuous stream."
- **Button:** "Next".

### 3. Step 2: Gallery
- **Action:** User taps "Next". App switches to Tab 2 (Gallery).
- **Overlay:** "This is the **Gallery**. Browse all your photos organized by year and category."
- **Button:** "Next".

### 4. Step 3: Search
- **Action:** User taps "Next". App switches to Tab 3 (Search).
- **Overlay:** "This is **Search**. Find memories by person, place, or category."
- **Button:** "Finish".

### 5. Completion
- **Action:** User taps "Finish".
- **Result:** Tour ends. App stays on Search (or returns to Timeline).
- **Next:** If the timeline is empty, the "Setup Wizard" button (Phase 2) is visible on the Timeline.

## Technical Implementation
- **`MainTabView`:** Will manage the `selectedTab` and the `tourStep`.
- **`TourOverlay`:** A reusable component that displays the explanation card.
- **ZStack:** The `TabView` will be wrapped in a `ZStack` to float the `TourOverlay` above it.

## Pros
- **Immersive:** User sees the actual app UI.
- **Educational:** Teaches navigation by doing.
- **Non-Obstructive:** The user can see the empty states of the views behind the card.
