import SwiftUI

struct AnimalFreePlayTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            Image(systemName: "fish.fill")
                .font(.system(size: 30))
                .foregroundStyle(palette.sky)
                .offset(x: -22, y: 8)
            Image(systemName: "bird.fill")
                .font(.system(size: 26))
                .foregroundStyle(palette.mustard)
                .offset(x: 14, y: -14)
            Image(systemName: "ladybug.fill")
                .font(.system(size: 22))
                .foregroundStyle(palette.berry)
                .offset(x: 22, y: 16)
            Image(systemName: "hare.fill")
                .font(.system(size: 24))
                .foregroundStyle(palette.sage)
                .offset(x: -4, y: -8)
        }
        .frame(width: 80, height: 60)
    }
}
