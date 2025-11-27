# Brainstorming: App Customization

## Goal
Allow users to personalize the app's appearance to make it feel like *their* private space.

## Proposed Features

### 1. Custom Background (Priority)
**Description:** Allow users to set a custom background image or color for the app.
**Implementation:**
- **Storage:** Save image to Documents directory (similar to `PhotoManager`) or use `AppStorage` for color hex.
- **UI:** A new "Appearance" section in Settings.
- **Effect:** The background is applied to the `ZStack` in `MainTabView` (behind the `TabView`).
- **Options:**
    - **Solid Colors:** Preset palette (Midnight, Deep Blue, Charcoal).
    - **Gradients:** Preset gradients.
    - **Custom Image:** Pick from Photo Library (with optional blur/dimming to ensure text readability).

### 2. Accent Color
**Description:** Change the primary brand color (currently Blue/Teal).
**Options:** Purple, Pink, Orange, Green, Monochrome.
**Implementation:** Update `Color.theme.accent` to read from `AppStorage`.

### 3. App Icon
**Description:** Choose from a set of alternative app icons.
**Options:**
- **Classic:** The default.
- **Dark:** Dark background, light glyph.
- **Light:** White background, dark glyph.
- **Retro:** Pixel art style.
**Implementation:** Use `UIApplication.shared.setAlternateIconName`.

### 4. Timeline Density
**Description:** Control how compact the timeline is.
**Options:**
- **Comfortable:** (Current) Large cards, more spacing.
- **Compact:** Smaller cards, less padding, more events per screen.

### 5. Font Style
**Description:** Change the typography.
**Options:**
- **Modern:** (Current) San Francisco Rounded.
- **Classic:** Serif font (New York).
- **Typewriter:** Monospaced (Courier) for a "journal" feel.

## Recommendation for MVP
Start with **Custom Background** and **Accent Color** as they have the highest visual impact for the lowest effort.
