import SwiftUI

struct DoorTileTall<Art: View>: View {
    let kicker: LocalizedStringKey
    let label: LocalizedStringKey
    let accent: KeyPath<Palette, Color>
    @ViewBuilder var art: () -> Art
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            ZStack {
                palette.paperHi

                Circle()
                    .fill(palette[keyPath: accent].opacity(0.18))
                    .frame(width: 220, height: 220)
                    .offset(x: -60, y: 80)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                art()
                    .scaleEffect(1.05)

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
                        .font(.system(size: 32, weight: .medium, design: .serif))
                        .kerning(-0.6)
                        .foregroundStyle(palette.ink)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(palette.paperHi)
                        .frame(width: 32, height: 32)
                        .background(palette.ink, in: .circle)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(.rect(cornerRadius: 32))
            .overlay {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(palette.line, lineWidth: 1.5)
            }
            .leShadow(.md, ink: palette.ink)
        }
        .buttonStyle(.plain)
    }
}
