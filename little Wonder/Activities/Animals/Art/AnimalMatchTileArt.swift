import SwiftUI

struct AnimalMatchTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "cat.fill")
                .font(.system(size: 30))
                .foregroundStyle(palette.sage)
            Image(systemName: "cat.fill")
                .font(.system(size: 30))
                .foregroundStyle(palette.ink.opacity(0.3))
                .padding(6)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(palette.ink.opacity(0.4), style: StrokeStyle(lineWidth: 2.5, dash: [5, 5]))
                }
        }
    }
}
