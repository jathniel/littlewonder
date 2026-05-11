import SwiftUI

struct LockedDoorTileWide<Art: View>: View {
    let kicker: LocalizedStringKey
    let label: LocalizedStringKey
    let blurb: LocalizedStringKey
    let price: LocalizedStringKey
    let accent: KeyPath<Palette, Color>
    @ViewBuilder var art: () -> Art
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                artPanel
                textPanel
                chipPanel
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(palette.sand)
            .clipShape(.rect(cornerRadius: 26))
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(palette.line, style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
            }
        }
        .buttonStyle(.plain)
    }

    private var artPanel: some View {
        ZStack {
            Circle()
                .fill(palette[keyPath: accent].opacity(0.14))
                .frame(width: 180, height: 180)
                .offset(x: -40, y: 50)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            art()
                .saturation(0.55)
                .opacity(0.8)
                .scaleEffect(0.85)
        }
        .frame(width: 190)
        .frame(maxHeight: .infinity)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(.clear)
                .frame(width: 1)
                .overlay {
                    Rectangle()
                        .strokeBorder(palette.line, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
        }
    }

    private var textPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(kicker)
                .font(FontStack.mono)
                .kerning(1)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)
            Text(label)
                .font(.system(size: 36, weight: .medium, design: .serif))
                .italic()
                .kerning(-0.6)
                .foregroundStyle(palette.ink)
            Text(blurb)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(palette.inkSoft)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 26)
    }

    private var chipPanel: some View {
        VStack(alignment: .trailing, spacing: 8) {
            LockPriceChip(price: price)
            Text("lockedDoorTileSoon")
                .font(FontStack.mono)
                .kerning(1)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)
        }
        .padding(.trailing, 22)
        .frame(maxHeight: .infinity, alignment: .center)
    }
}
