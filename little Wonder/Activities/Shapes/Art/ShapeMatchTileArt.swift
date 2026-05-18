import SwiftUI

struct ShapeMatchTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            PrimitiveShape(kind: .circle, size: 70, fill: palette.terracotta)
                .offset(x: -14, y: 8)
            Circle()
                .stroke(palette.line, lineWidth: 3)
                .frame(width: 70, height: 70)
                .offset(x: 14, y: -6)
        }
    }
}
