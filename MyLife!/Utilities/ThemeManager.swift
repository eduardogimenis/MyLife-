import SwiftUI
import Combine

@MainActor
class ThemeManager: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    // ... (rest of the class)
    
    // MARK: - Enums
    
    enum AppAccentColor: String, CaseIterable, Identifiable {
        case blue, purple, pink, orange, teal, green
        var id: String { rawValue }
        
        var color: Color {
            switch self {
            case .blue: return .blue
            case .purple: return .purple
            case .pink: return .pink
            case .orange: return .orange
            case .teal: return .teal
            case .green: return .green
            }
        }
    }
    
    enum BackgroundStyle: String, CaseIterable, Identifiable {
        case solid, gradient, image
        var id: String { rawValue }
    }
    
    enum TimelineDensity: String, CaseIterable, Identifiable {
        case comfortable, compact
        var id: String { rawValue }
    }
    
    enum FontDesign: String, CaseIterable, Identifiable {
        case `default`, serif, monospaced, rounded
        var id: String { rawValue }
        
        var design: Font.Design {
            switch self {
            case .default: return .default
            case .serif: return .serif
            case .monospaced: return .monospaced
            case .rounded: return .rounded
            }
        }
    }
    
    enum AppDynamicTypeSize: String, CaseIterable, Identifiable {
        case small, medium, large, xLarge, xxLarge, xxxLarge
        var id: String { rawValue }
        
        var size: DynamicTypeSize {
            switch self {
            case .small: return .small
            case .medium: return .medium
            case .large: return .large
            case .xLarge: return .xLarge
            case .xxLarge: return .xxLarge
            case .xxxLarge: return .xxxLarge
            }
        }
        
        var label: String {
            switch self {
            case .small: return "A"
            case .medium: return "A"
            case .large: return "A"
            case .xLarge: return "A"
            case .xxLarge: return "A"
            case .xxxLarge: return "A"
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            case .large: return 20
            case .xLarge: return 24
            case .xxLarge: return 28
            case .xxxLarge: return 32
            }
        }
    }
    
    // MARK: - Published Properties
    
    // MARK: - Properties backed by UserDefaults
    
    var accentColorRaw: String {
        get { UserDefaults.standard.string(forKey: "appAccentColor") ?? AppAccentColor.blue.rawValue }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue, forKey: "appAccentColor")
        }
    }
    
    var backgroundStyleRaw: String {
        get { UserDefaults.standard.string(forKey: "appBackgroundStyle") ?? BackgroundStyle.solid.rawValue }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue, forKey: "appBackgroundStyle")
        }
    }
    
    @Published var customBackgroundR: Double {
        didSet { UserDefaults.standard.set(customBackgroundR, forKey: "appCustomBackgroundR") }
    }
    
    @Published var customBackgroundG: Double {
        didSet { UserDefaults.standard.set(customBackgroundG, forKey: "appCustomBackgroundG") }
    }
    
    @Published var customBackgroundB: Double {
        didSet { UserDefaults.standard.set(customBackgroundB, forKey: "appCustomBackgroundB") }
    }
    
    @Published var customBackgroundA: Double {
        didSet { UserDefaults.standard.set(customBackgroundA, forKey: "appCustomBackgroundA") }
    }
    
    var isBackgroundBlurred: Bool {
        get { UserDefaults.standard.bool(forKey: "appIsBackgroundBlurred") }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue, forKey: "appIsBackgroundBlurred")
        }
    }
    
    var timelineDensityRaw: String {
        get { UserDefaults.standard.string(forKey: "appTimelineDensity") ?? TimelineDensity.comfortable.rawValue }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue, forKey: "appTimelineDensity")
        }
    }
    
    var fontDesignRaw: String {
        get { UserDefaults.standard.string(forKey: "appFontDesign") ?? FontDesign.rounded.rawValue }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue, forKey: "appFontDesign")
        }
    }
    
    var dynamicTypeSizeRaw: String {
        get { UserDefaults.standard.string(forKey: "appDynamicTypeSize") ?? AppDynamicTypeSize.large.rawValue }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue, forKey: "appDynamicTypeSize")
        }
    }
    
    @Published var backgroundImage: UIImage?
    
    // MARK: - Background Logic
    
    func backgroundView() -> some View {
        ZStack {
            switch backgroundStyle {
            case .solid:
                customBackgroundColor
                SmudgeBackgroundView(color: accentColor, opacity: 0.2)
            case .gradient:
                LinearGradient(
                    colors: [customBackgroundColor, accentColor.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                SmudgeBackgroundView(color: .white, opacity: 0.15)
            case .image:
                if let image = backgroundImage {
                    GeometryReader { proxy in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                    }
                    .ignoresSafeArea()
                    .blur(radius: isBackgroundBlurred ? 20 : 0)
                    .overlay(Color.black.opacity(0.3).ignoresSafeArea())
                } else {
                    Color.theme.background
                }
            }
        }
        .ignoresSafeArea()
    }
    

    
    // MARK: - Initialization
    
    init() {
        self.customBackgroundR = UserDefaults.standard.double(forKey: "appCustomBackgroundR")
        self.customBackgroundG = UserDefaults.standard.double(forKey: "appCustomBackgroundG")
        self.customBackgroundB = UserDefaults.standard.double(forKey: "appCustomBackgroundB")
        
        if UserDefaults.standard.object(forKey: "appCustomBackgroundA") == nil {
            self.customBackgroundA = 1.0 // Default to opaque if not set
        } else {
            self.customBackgroundA = UserDefaults.standard.double(forKey: "appCustomBackgroundA")
        }
        
        loadBackgroundImage()
    }
    
    // MARK: - Computed Properties
    
    var accentColor: Color {
        AppAccentColor(rawValue: accentColorRaw)?.color ?? .blue
    }
    
    var backgroundStyle: BackgroundStyle {
        BackgroundStyle(rawValue: backgroundStyleRaw) ?? .solid
    }
    
    var customBackgroundColor: Color {
        if customBackgroundA == 0 {
             return Color.theme.background
        }
        return Color(red: customBackgroundR, green: customBackgroundG, blue: customBackgroundB, opacity: customBackgroundA)
    }

    var contrastingTextColor: Color {
        switch backgroundStyle {
        case .solid, .gradient:
            // Calculate luminance of customBackgroundColor
            let uic = UIColor(customBackgroundColor)
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            
            // Try to get components, defaulting to dark (white text) if fails
            guard uic.getRed(&r, green: &g, blue: &b, alpha: &a) else { return .white }
            
            // Luminance formula
            let luminance = 0.299 * r + 0.587 * g + 0.114 * b
            
            return luminance > 0.6 ? .black : .white
        case .image:
            // Images have a dark overlay, so white text usually pops better
            return .white
        }
    }
    
    func setCustomBackgroundColor(_ color: Color) {
        let uic = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        // Try direct extraction
        if uic.getRed(&r, green: &g, blue: &b, alpha: &a) {
            saveColor(r: r, g: g, b: b, a: a)
            return
        }
        
        // Try sRGB conversion
        if let cgColor = uic.cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil) {
            let srgbColor = UIColor(cgColor: cgColor)
            if srgbColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
                saveColor(r: r, g: g, b: b, a: a)
                return
            }
        }
        
        print("ThemeManager: Failed to extract RGB components from color")
    }
    
    private func saveColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        print("ThemeManager: Saving color R:\(r) G:\(g) B:\(b) A:\(a)")
        objectWillChange.send()
        self.customBackgroundR = Double(r)
        self.customBackgroundG = Double(g)
        self.customBackgroundB = Double(b)
        self.customBackgroundA = Double(a)
    }
    
    var timelineDensity: TimelineDensity {
        TimelineDensity(rawValue: timelineDensityRaw) ?? .comfortable
    }
    
    var fontDesign: Font.Design {
        FontDesign(rawValue: fontDesignRaw)?.design ?? .rounded
    }
    
    var dynamicTypeSize: DynamicTypeSize {
        AppDynamicTypeSize(rawValue: dynamicTypeSizeRaw)?.size ?? .large
    }
    

    
    // MARK: - Image Management
    
    func saveBackgroundImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent("custom_background.jpg")
            try? data.write(to: filename)
            self.backgroundImage = image
        }
    }
    
    func loadBackgroundImage() {
        let filename = getDocumentsDirectory().appendingPathComponent("custom_background.jpg")
        if let data = try? Data(contentsOf: filename), let image = UIImage(data: data) {
            self.backgroundImage = image
        }
    }
    
    func deleteBackgroundImage() {
        let filename = getDocumentsDirectory().appendingPathComponent("custom_background.jpg")
        try? FileManager.default.removeItem(at: filename)
        self.backgroundImage = nil
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct SmudgeBackgroundView: View {
    var color: Color
    var opacity: Double
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Top Left Smudge
                Circle()
                    .fill(color)
                    .frame(width: proxy.size.width * 0.9, height: proxy.size.width * 0.9)
                    .blur(radius: 80)
                    .offset(x: -proxy.size.width * 0.3, y: -proxy.size.height * 0.2)
                    .opacity(opacity)
                
                // Bottom Right Smudge
                Circle()
                    .fill(color)
                    .frame(width: proxy.size.width * 0.9, height: proxy.size.width * 0.9)
                    .blur(radius: 80)
                    .offset(x: proxy.size.width * 0.3, y: proxy.size.height * 0.2)
                    .opacity(opacity)
            }
        }
        .allowsHitTesting(false)
    }
}
