import SwiftUI

struct ColorFindTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        let swatches: [Color] = [palette.sage, palette.berry, palette.sky, palette.sage, palette.mustard, palette.sage]
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(22), spacing: 6), count: 3), spacing: 6) {
            ForEach(swatches.enumerated(), id: \.offset) { index, color in
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(color)
                    .frame(width: 22, height: 22)
                    .overlay {
                        if color == palette.sage {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
            }
        }
        .frame(width: 84)
    }
}
