import SwiftUI

struct NumberFreePlayTileArt: View {
    @Environment(\.palette) private var palette

    private let stamps: [(value: Int, color: KeyPath<Palette, Color>, offset: CGSize, scale: CGFloat)] = [
        (5, \Palette.berry,   CGSize(width: -22, height: -6), 1.0),
        (2, \Palette.mustard, CGSize(width: 16, height: -18), 0.8),
        (8, \Palette.sky,     CGSize(width: 20, height: 14), 1.1),
        (3, \Palette.sage,    CGSize(width: -8, height: 20), 0.75)
    ]

    var body: some View {
        ZStack {
            ForEach(stamps.enumerated(), id: \.offset) { _, stamp in
                Text(stamp.value, format: .number)
                    .font(.system(size: 34, weight: .regular, design: .serif))
                    .foregroundStyle(palette[keyPath: stamp.color])
                    .scaleEffect(stamp.scale)
                    .offset(stamp.offset)
            }
        }
    }
}
