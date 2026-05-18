import SwiftUI

struct ShapeSortTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 10) {
            PrimitiveShape(kind: .square,   size: 46, fill: palette.sage)
            PrimitiveShape(kind: .circle,   size: 46, fill: palette.sage)
            PrimitiveShape(kind: .triangle, size: 46, fill: palette.sage)
        }
    }
}
