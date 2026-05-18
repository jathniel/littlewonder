import SwiftUI

struct DoorTile<Art: View>: View {
    let kicker: LocalizedStringKey
    let label: LocalizedStringKey
    let accent: KeyPath<Palette, Color>
    var size: CGFloat = 320
    @ViewBuilder var art: () -> Art
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            DoorTileContents(
                kicker: kicker,
                label: label,
                accent: accent,
                size: size,
                art: art
            )
        }
        .buttonStyle(.plain)
    }
}

private struct DoorTileContents<Art: View>: View {
    let kicker: LocalizedStringKey
    let label: LocalizedStringKey
    let accent: KeyPath<Palette, Color>
    let size: CGFloat
    @ViewBuilder var art: () -> Art

    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            palette.paperHi

            Circle()
                .fill(palette[keyPath: accent].opacity(0.16))
                .frame(width: size * 0.9, height: size * 0.9)
                .position(x: size * 0.25, y: size * 0.80)

            WoodGrainBackground(color: palette.ink, opacity: 0.04)

            art()

            Text(kicker)
                .font(FontStack.mono)
                .kerning(1)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)
                .padding(.leading, 22)
                .padding(.top, 22)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            HStack(alignment: .center) {
                Text(label)
                    .font(.system(size: size * 0.13, weight: .medium, design: .serif))
                    .kerning(-0.5)
                    .foregroundStyle(palette.ink)
                Spacer()
                ArrowChip()
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: 36))
        .overlay {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(palette.line, lineWidth: 1.5)
        }
        .leShadow(.md, ink: palette.ink)
    }
}

private struct ArrowChip: View {
    @Environment(\.palette) private var palette

    var body: some View {
        Image(systemName: "arrow.right")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(palette.paperHi)
            .frame(width: 36, height: 36)
            .background(palette.ink, in: .circle)
    }
}
