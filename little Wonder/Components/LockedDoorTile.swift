import SwiftUI

struct LockedDoorTile<Art: View>: View {
    let kicker: LocalizedStringKey
    let label: LocalizedStringKey
    let price: LocalizedStringKey
    let accent: KeyPath<Palette, Color>
    @ViewBuilder var art: () -> Art
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            ZStack {
                palette.sand

                Circle()
                    .fill(palette[keyPath: accent].opacity(0.10))
                    .frame(width: 200, height: 200)
                    .offset(x: -50, y: 70)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                art()
                    .saturation(0.55)
                    .opacity(0.7)

                Text(kicker)
                    .font(FontStack.mono)
                    .kerning(1)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)
                    .padding(.leading, 22)
                    .padding(.top, 22)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                LockPriceChip(price: price)
                    .padding(.trailing, 18)
                    .padding(.top, 18)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

                HStack(alignment: .center) {
                    Text(label)
                        .font(.system(size: 30, weight: .medium, design: .serif))
                        .italic()
                        .kerning(-0.6)
                        .foregroundStyle(palette.ink)
                    Spacer()
                    Text("lockedDoorTileSoon")
                        .font(FontStack.mono)
                        .kerning(1)
                        .textCase(.uppercase)
                        .foregroundStyle(palette.inkSoft)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(.rect(cornerRadius: 32))
            .overlay {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .strokeBorder(palette.line, style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
            }
        }
        .buttonStyle(.plain)
    }
}

