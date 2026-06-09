import SwiftUI

struct ColorMixTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(palette.berry).frame(width: 30, height: 30)
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(palette.inkSoft)
            Circle().fill(palette.mustard).frame(width: 30, height: 30)
            Image(systemName: "equal")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(palette.inkSoft)
            Circle().fill(palette.terracotta).frame(width: 34, height: 34)
        }
    }
}
