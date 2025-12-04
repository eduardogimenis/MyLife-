import SwiftUI

extension Font {
    static let hero = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let sectionHeader = Font.system(.title2, design: .rounded).weight(.semibold)
    static let bodyText = Font.system(.body, design: .default).weight(.regular)
    static let captionText = Font.system(.caption, design: .default).weight(.medium)
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
