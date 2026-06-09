import SwiftUI

struct ColorMatchTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(palette.berry)
                .frame(width: 40, height: 40)
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(palette.berry.opacity(0.7), style: StrokeStyle(lineWidth: 2.5, dash: [5, 5]))
                .frame(width: 40, height: 40)
        }
    }
}
