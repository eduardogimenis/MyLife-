import SwiftUI
import PhotosUI

struct AppearanceSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        ZStack {
            themeManager.backgroundView()
            
            Form {
                Section(header: Text("Accent Color")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(ThemeManager.AppAccentColor.allCases) { color in
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
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(height: 60)
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Background")) {
                    Picker("Style", selection: $themeManager.backgroundStyleRaw) {
                        ForEach(ThemeManager.BackgroundStyle.allCases) { style in
                            Text(style.rawValue.capitalized).tag(style.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    
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
                                Spacer()
                                if hasBackgroundImage {
                                    Text("Change")
                                        .foregroundColor(.secondary)
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
                                Slider(value: $themeManager.backgroundBlurRadius, in: 0...20, step: 1)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Tint Opacity: \(Int(themeManager.backgroundTintOpacity * 100))%")
                                Slider(value: $themeManager.backgroundTintOpacity, in: 0...1)
                            }
                            
                            ColorPicker("Tint Color", selection: Binding(
                                get: { themeManager.backgroundTintColor },
                                set: { themeManager.setBackgroundTintColor($0) }
                            ))
                            
                            Button(role: .destructive) {
                                themeManager.deleteBackgroundImage()
                            } label: {
                                Label("Remove Image", systemImage: "trash")
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Typography")) {
                    Picker("Font Style", selection: $themeManager.fontDesignRaw) {
                        ForEach(ThemeManager.FontDesign.allCases) { design in
                            Text(design.rawValue.capitalized).tag(design.rawValue)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Text Size")
                        HStack {
                            ForEach(ThemeManager.AppDynamicTypeSize.allCases) { size in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(themeManager.dynamicTypeSizeRaw == size.rawValue ? Color.theme.accent.opacity(0.2) : Color.clear)
                                    
                                    Text(size.label)
                                        .font(.system(size: size.fontSize))
                                        .fontWeight(themeManager.dynamicTypeSizeRaw == size.rawValue ? .bold : .regular)
                                        .foregroundColor(themeManager.contrastingTextColor)
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
                
                Section(header: Text("Timeline Density")) {
                    Picker("Density", selection: $themeManager.timelineDensityRaw) {
                        ForEach(ThemeManager.TimelineDensity.allCases) { density in
                            Text(density.rawValue.capitalized).tag(density.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.clear)
                
                Section {
                    HStack {
                        Text("Preview")
                        Spacer()
                        Text("MyLife!")
                            .font(.system(.body, design: themeManager.fontDesign))
                            .foregroundColor(themeManager.accentColor)
                    }
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
