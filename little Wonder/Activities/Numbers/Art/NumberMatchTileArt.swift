import SwiftUI

struct NumberMatchTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 12) {
            Text(verbatim: "2")
                .font(.system(size: 40, weight: .regular, design: .serif))
                .foregroundStyle(palette.terracotta)
            VStack(spacing: 6) {
                PrimitiveShape(kind: .circle, size: 18, fill: palette.terracotta)
                PrimitiveShape(kind: .circle, size: 18, fill: palette.terracotta)
            }
        }
    }
}
