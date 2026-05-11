import SwiftUI

struct WoodGrainBackground: View {
    var color: Color
    var opacity: Double = 0.04

    var body: some View {
        Canvas { context, size in
            let tile: CGFloat = 80
            let cols = Int((size.width / tile).rounded(.up)) + 1
            let rows = Int((size.height / tile).rounded(.up)) + 1
            let lines: [(y: CGFloat, width: CGFloat)] = [
                (12, 0.8),
                (30, 0.6),
                (52, 0.7),
                (70, 0.5),
            ]
            for row in 0..<rows {
                for col in 0..<cols {
                    let ox = CGFloat(col) * tile
                    let oy = CGFloat(row) * tile
                    for line in lines {
                        var path = Path()
                        path.move(to: CGPoint(x: ox, y: oy + line.y))
                        path.addQuadCurve(
                            to: CGPoint(x: ox + tile / 2, y: oy + line.y),
                            control: CGPoint(x: ox + tile / 4, y: oy + line.y - 4)
                        )
                        path.addQuadCurve(
                            to: CGPoint(x: ox + tile, y: oy + line.y),
                            control: CGPoint(x: ox + 3 * tile / 4, y: oy + line.y + 4)
                        )
                        context.stroke(
                            path,
                            with: .color(color.opacity(opacity)),
                            lineWidth: line.width
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
