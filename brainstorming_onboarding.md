# Brainstorming: Two-Phase Onboarding Strategy

## Phase 1: The App Tour (Welcome Carousel)
**Goal:** Educate the user on the app's core navigation and features before they start.
**Location:** Appears on first launch (modal).

### Slides
1.  **Timeline:** "Your life story in a continuous stream." (Icon: `clock.arrow.circlepath`)
2.  **Gallery:** "All your memories in one place." (Icon: `photo.stack`)
3.  **Search:** "Find any moment instantly." (Icon: `magnifyingglass`)
4.  **Get Started:** "Ready to build your timeline?" -> Dismisses tour.

## Phase 2: The Setup Wizard (Empty State)
**Goal:** Populate the timeline when it's empty.
**Location:** Embedded in the `TimelineView` when `events.isEmpty`. Replaces the current static "No Events" view.

### Flow (Triggered by "Start Setup" button on empty timeline)

1.  **The Beginning (Birth)**
    - Input: Birthday.
    - Result: "Born" event.

2.  **Career & Education (LinkedIn Import)**
    - Action: "Import from LinkedIn" button.
    - Result: Bulk creation of Work/Education events.

3.  **Family & Relationships**
    - Input: List of key people (Spouse, Children).
    - Result: Events with "Relationship" or "Family" categories.

4.  **Major Moves (Living)**
    - Input: Current City + Start Date.
    - Result: "Living" event.

5.  **Retirement (Conditional)**
    - If Age > 55, ask about retirement date.

6.  **Completion**
    - Animation: "Building your timeline..."
    - Result: User lands on the populated Timeline View.

## Design Notes
- **Visuals:** Rely on the app's existing Category colors and icons. No need for custom illustrations.
- **Integration:** The Wizard is a modal sheet presented from the Timeline.
