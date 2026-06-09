import SwiftUI

struct ColorFreePlayTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            Circle().fill(palette.sky).frame(width: 34, height: 34).offset(x: -22, y: 8)
            Circle().fill(palette.mustard).frame(width: 28, height: 28).offset(x: 14, y: -14)
            Circle().fill(palette.berry).frame(width: 24, height: 24).offset(x: 22, y: 16)
            Circle().fill(palette.sage).frame(width: 20, height: 20).offset(x: -6, y: -6)
        }
        .frame(width: 80, height: 60)
    }
}
