import SwiftUI

struct ActivityCard<Art: View>: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let accent: KeyPath<Palette, Color>
    var sideLength: CGFloat = 280
    @ViewBuilder var art: () -> Art
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack {
                    palette[keyPath: accent].opacity(0.13)
                    art()
                }
                .frame(height: sideLength * 0.62)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(palette.line)
                        .frame(height: 1)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 22, weight: .medium, design: .serif))
                        .foregroundStyle(palette.ink)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.inkSoft)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
            }
            .frame(width: sideLength, height: sideLength)
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
