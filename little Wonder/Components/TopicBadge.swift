import SwiftUI

struct TopicBadge: View {
    let label: LocalizedStringKey
    let accent: KeyPath<Palette, Color>

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Circle()
                .fill(palette[keyPath: accent])
                .frame(width: 10, height: 10)
            Text(label)
                .font(FontStack.label)
                .kerning(0.3)
                .textCase(.uppercase)
        }
        .padding(.vertical, 6)
        .padding(.leading, 10)
        .padding(.trailing, 14)
        .background(palette.paperHi, in: .capsule)
        .overlay { Capsule().stroke(palette.line, lineWidth: 1) }
        .foregroundStyle(palette.ink)
    }
}
