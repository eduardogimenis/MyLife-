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
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            HStack {
                                Label("Select Photo", systemImage: "photo")
                                Spacer()
                                if themeManager.backgroundImage != nil {
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
                            Toggle("Blur Background", isOn: $themeManager.isBackgroundBlurred)
                            
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
