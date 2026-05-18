import SwiftUI

struct ShapeTraceTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            Circle()
                .stroke(palette.line, style: StrokeStyle(lineWidth: 2.5, dash: [4, 6]))
                .frame(width: 72, height: 72)

            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(palette.oak, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 72, height: 72)

            Circle()
                .fill(palette.oak)
                .frame(width: 8, height: 8)
                .offset(x: 0, y: -36)
        }
    }
}
