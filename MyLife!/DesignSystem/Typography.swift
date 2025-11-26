import SwiftUI

extension Font {
    static let hero = Font.system(size: 34, weight: .bold, design: .rounded)
    static let sectionHeader = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let bodyText = Font.system(size: 17, weight: .regular, design: .default)
    static let captionText = Font.system(size: 13, weight: .medium, design: .default)
}

struct TypographyPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hero Title").font(.hero)
            Text("Section Header").font(.sectionHeader)
            Text("Body text goes here.").font(.bodyText)
            Text("Caption text").font(.captionText)
        }
    }
}
