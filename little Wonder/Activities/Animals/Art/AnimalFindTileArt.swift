import SwiftUI

struct AnimalFindTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        let symbols: [(String, Color)] = [
            ("bird.fill", palette.sky), ("hare.fill", palette.mustard), ("bird.fill", palette.sky),
            ("ant.fill", palette.ink), ("bird.fill", palette.sky), ("fish.fill", palette.terracotta),
        ]
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(24), spacing: 6), count: 3), spacing: 6) {
            ForEach(symbols.enumerated(), id: \.offset) { _, entry in
                Image(systemName: entry.0)
                    .font(.system(size: 18))
                    .foregroundStyle(entry.1)
                    .frame(width: 24, height: 24)
            }
        }
        .frame(width: 90)
    }
}
