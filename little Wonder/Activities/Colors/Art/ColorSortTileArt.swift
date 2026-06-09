import SwiftUI

struct ColorSortTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 10) {
            Circle().fill(palette.berry).frame(width: 24, height: 24)
            Circle().fill(palette.sky).frame(width: 30, height: 30)
            Circle().fill(palette.mustard).frame(width: 24, height: 24)
        }
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(palette.line, lineWidth: 2)
                .frame(width: 96, height: 18)
                .offset(y: 22)
        }
    }
}
