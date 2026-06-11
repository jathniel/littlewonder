import SwiftUI

struct AnimalSortTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "dog.fill")
                .font(.system(size: 24))
                .foregroundStyle(palette.oak)
            Image(systemName: "ladybug.fill")
                .font(.system(size: 24))
                .foregroundStyle(palette.berry)
            Image(systemName: "fish.fill")
                .font(.system(size: 24))
                .foregroundStyle(palette.sky)
        }
        .overlay(alignment: .bottom) {
            HStack(spacing: 10) {
                Image(systemName: "house.fill")
                Image(systemName: "leaf.fill")
                Image(systemName: "drop.fill")
            }
            .font(.system(size: 12))
            .foregroundStyle(palette.inkSoft)
            .offset(y: 24)
        }
    }
}
