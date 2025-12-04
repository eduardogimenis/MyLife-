import SwiftUI
import PhotosUI

struct AppearanceSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        let textColor = themeManager.contrastingTextColor
        
        ZStack {
            themeManager.backgroundView()
            
            Form {
                Section(header: Text("Theme Gallery").foregroundColor(textColor).textContrast()) {
                    NavigationLink(destination: ThemeSelectionView()) {
                        Label("Browse Themes", systemImage: "paintpalette.fill")
                            .foregroundColor(textColor)
                            .textContrast()
                    }
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Accent Color").foregroundColor(textColor).textContrast()) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(ThemeManager.AppAccentColor.allCases.filter { $0 != .custom }) { color in
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: themeManager.accentColorRaw == color.rawValue ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            themeManager.accentColorRaw = color.rawValue
                                        }
                                    }
                            }
                            
                            // Custom Color Button
                            Button {
                                withAnimation {
                                    themeManager.accentColorRaw = ThemeManager.AppAccentColor.custom.rawValue
                                }
                            } label: {
                                Circle()
                                    .fill(
                                        AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center)
                                    )
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: themeManager.accentColorRaw == ThemeManager.AppAccentColor.custom.rawValue ? 3 : 0)
                                    )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(height: 60)
                    
                    if themeManager.accentColorRaw == ThemeManager.AppAccentColor.custom.rawValue {
                        ColorPicker("Custom Accent Color", selection: Binding(
                            get: { themeManager.customAccentColor },
                            set: { themeManager.setCustomAccentColor($0) }
                        ))
                    }
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Background").foregroundColor(textColor).textContrast()) {
                    // Custom Segmented Picker for better styling control
                    HStack(spacing: 0) {
                        ForEach(ThemeManager.BackgroundStyle.allCases) { style in
                            Text(style.rawValue.capitalized)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(themeManager.backgroundStyleRaw == style.rawValue ? .white : .white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(themeManager.backgroundStyleRaw == style.rawValue ? Color.gray.opacity(0.5) : Color.clear)
                                        .padding(2)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        themeManager.backgroundStyleRaw = style.rawValue
                                    }
                                }
                        }
                    }
                    .padding(2)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(8)
                    
                    if themeManager.backgroundStyle == .solid || themeManager.backgroundStyle == .gradient {
                        ColorPicker("Custom Base Color", selection: Binding(
                            get: { themeManager.customBackgroundColor },
                            set: { themeManager.setCustomBackgroundColor($0) }
                        ))
                    }
                    
                    if themeManager.backgroundStyle == .image {
                        let hasBackgroundImage = themeManager.backgroundImage != nil
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            HStack {
                                Label("Select Photo", systemImage: "photo")
                                    .foregroundColor(textColor) // Standard text color
                                    .textContrast()
                                Spacer()
                                if hasBackgroundImage {
                                    Text("Change")
                                        .foregroundColor(themeManager.contrastingTextColor.opacity(0.7))
                                        .textContrast()
                                }
                            }
                        }
                        .onChange(of: selectedPhotoItem) { _, newItem in
                            Task { @MainActor in
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    themeManager.saveBackgroundImage(image)
                                }
                            }
                        }
                        
                        if themeManager.backgroundImage != nil {
                            VStack(alignment: .leading) {
                                Text("Blur: \(Int(themeManager.backgroundBlurRadius))")
                                    .foregroundColor(textColor)
                                    .textContrast()
                                Slider(value: $themeManager.backgroundBlurRadius, in: 0...20, step: 1)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Tint Opacity: \(Int(themeManager.backgroundTintOpacity * 100))%")
                                    .foregroundColor(textColor)
                                    .textContrast()
                                Slider(value: $themeManager.backgroundTintOpacity, in: 0...1)
                            }
                            
                            ColorPicker("Tint Color", selection: Binding(
                                get: { themeManager.backgroundTintColor },
                                set: { themeManager.setBackgroundTintColor($0) }
                            ))
                            
                            Button {
                                themeManager.deleteBackgroundImage()
                            } label: {
                                Label("Remove Image", systemImage: "trash")
                                    .foregroundColor(textColor) // Standard text color
                                    .textContrast()
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Typography").foregroundColor(textColor).textContrast()) {
                    Picker("Font Style", selection: $themeManager.fontDesignRaw) {
                        ForEach(ThemeManager.FontDesign.allCases) { design in
                            Text(design.rawValue.capitalized).tag(design.rawValue)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Text Size")
                            .foregroundColor(textColor)
                            .textContrast()
                        HStack {
                            ForEach(ThemeManager.AppDynamicTypeSize.allCases) { size in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(themeManager.dynamicTypeSizeRaw == size.rawValue ? Color.theme.accent.opacity(0.2) : Color.clear)
                                    
                                    Text(size.label)
                                        .font(.system(size: size.fontSize))
                                        .fontWeight(themeManager.dynamicTypeSizeRaw == size.rawValue ? .bold : .regular)
                                        .foregroundColor(themeManager.contrastingTextColor)
                                        .textContrast()
                                }
                                .frame(height: 50)
                                .onTapGesture {
                                    withAnimation {
                                        themeManager.dynamicTypeSizeRaw = size.rawValue
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Appearance")
    }
}

#Preview {
    AppearanceSettingsView()
        .environmentObject(ThemeManager())
}
