import SwiftUI

struct ShapeBuildTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            PrimitiveShape(kind: .triangle, size: 48, fill: palette.terracotta)
                .offset(y: -22)
            PrimitiveShape(kind: .square, size: 48, fill: palette.oak)
                .offset(y: 8)
            RoundedRectangle(cornerRadius: 2)
                .fill(palette.ink)
                .frame(width: 12, height: 22)
                .offset(y: 16)
        }
    }
}
