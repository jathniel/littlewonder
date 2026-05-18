import SwiftUI

struct ShapeFreePlayTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 12) {
            PrimitiveShape(kind: .circle, size: 44, fill: palette.berry)
            PrimitiveShape(kind: .square, size: 44, fill: palette.mustard)
                .rotationEffect(.degrees(12))
            PrimitiveShape(kind: .triangle, size: 44, fill: palette.sage)
            PrimitiveShape(kind: .hexagon, size: 44, fill: palette.sky)
        }
    }
}
