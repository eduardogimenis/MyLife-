# Brainstorming: Gallery View Improvements

## Current State
- Simple grid layout (`LazyVGrid`).
- Displays all events with photos sorted by date.
- Basic detail view.
- No filtering or grouping.

## Proposed Improvements

### 1. Advanced Filtering
**Goal:** Allow users to find specific photos easily.
- **Category Filter:** Reuse `CategoryFilterView` to show only photos from specific categories (e.g., "Travel", "Family").
- **People Filter:** Reuse `PeopleFilterView` to show photos containing specific people.
- **Date Range:** (Optional) Filter by specific year.

### 2. Smart Grouping
**Goal:** Organize the continuous stream of photos.
- **Group by Year/Month:** Use `Section` headers in the grid to separate photos by time periods. This gives context to the timeline.

### 3. Enhanced Layout
**Goal:** Make the gallery look more premium.
- **Masonry / Staggered Grid:** Instead of uniform squares, allow images to maintain their aspect ratio or use a "featured" layout (some large, some small).
    - *Note:* True masonry is hard in pure SwiftUI, but we can do a "Pinterest-style" 2-column stack.
- **Hero Animations:** Smooth transition from the grid thumbnail to the full-screen detail view.

### 4. Immersive Detail View
**Goal:** Better photo viewing experience.
- **Swipeable Pager:** When tapping a photo, open a full-screen view that allows swiping left/right to browse adjacent photos without going back to the grid.
- **Zoom & Pan:** Allow users to pinch-to-zoom on photos.

## Recommended First Steps (MVP+)
1.  **Add Filters:** Implement the Category and People filters (High impact, low effort since components exist).
2.  **Group by Year:** Add section headers (High value for timeline context).
3.  **Improve Detail View:** Make it a swipeable pager if possible, or at least improve the visual hierarchy.
