import SwiftUI

struct ActivityCardWide<Art: View>: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let accent: KeyPath<Palette, Color>
    @ViewBuilder var art: () -> Art
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                ZStack {
                    palette[keyPath: accent].opacity(0.13)
                    art()
                }
                .frame(width: 220)
                .frame(maxHeight: .infinity)
                .overlay(alignment: .trailing) {
                    Rectangle().fill(palette.line).frame(width: 1)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 28, weight: .medium, design: .serif))
                        .foregroundStyle(palette.ink)
                    Text(subtitle)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.inkSoft)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 26)
            }
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(palette.paperHi)
            .clipShape(.rect(cornerRadius: 28))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(palette.line, lineWidth: 1.5)
            }
            .leShadow(.md, ink: palette.ink)
        }
        .buttonStyle(.plain)
    }
}
