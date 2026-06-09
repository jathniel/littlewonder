import SwiftUI

struct NumberCountTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                PrimitiveShape(kind: .circle, size: 26, fill: palette.sky)
                    .opacity(index == 2 ? 0.35 : 1)
            }
        }
        .overlay(alignment: .topTrailing) {
            Text(verbatim: "3")
                .font(.system(size: 30, weight: .regular, design: .serif))
                .foregroundStyle(palette.ink)
                .offset(x: 18, y: -22)
        }
    }
}
