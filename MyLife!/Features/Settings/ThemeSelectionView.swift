import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            themeManager.backgroundView()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(ThemeManager.ThemePreset.allPresets) { preset in
                        Button {
                            withAnimation {
                                themeManager.apply(preset: preset)
                            }
                        } label: {
                            ThemePresetCard(preset: preset)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Theme Gallery")
        .toolbarColorScheme(themeManager.contrastingTextColor == .white ? .dark : .light, for: .navigationBar)
    }
}

struct ThemePresetCard: View {
    let preset: ThemeManager.ThemePreset
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            if let image = UIImage(named: preset.imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                // Fallback gradient
                LinearGradient(
                    colors: [preset.customColor, preset.accentColor.color],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 180)
                .frame(maxWidth: .infinity)
            }
            
            // Gradient Overlay for Text
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: preset.icon)
                        .foregroundColor(preset.accentColor == .custom ? (preset.customAccentColor ?? .white) : preset.accentColor.color)
                    Spacer()
                    
                    let isSelected = themeManager.accentColorRaw == preset.accentColor.rawValue &&
                                   themeManager.fontDesignRaw == preset.fontDesign.rawValue &&
                                   (preset.accentColor != .custom || themeManager.customAccentColor == preset.customAccentColor)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                .font(.title3)
                .padding(.bottom, 4)
                
                Text(preset.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(preset.fontDesign == .default ? "Default Font" : "\(preset.fontDesign)".capitalized + " Font")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
        .background(Color.black) // Fallback background
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        ThemeSelectionView()
            .environmentObject(ThemeManager())
    }
}
