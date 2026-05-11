import SwiftUI

struct PrimitiveShape: View {
    let kind: ShapeKind
    var size: CGFloat = 80
    var fill: Color = .clear
    var stroke: Color? = nil
    var strokeWidth: CGFloat = 0

    var body: some View {
        Group {
            switch kind {
            case .circle:     painted(Circle())
            case .square:     painted(SquarePrimitiveShape())
            case .rectangle:  painted(RectanglePrimitiveShape())
            case .triangle:   painted(TrianglePrimitiveShape())
            case .oval:       painted(OvalPrimitiveShape())
            case .hexagon:    painted(HexagonPrimitiveShape())
            case .star:       painted(StarPrimitiveShape())
            case .heart:      painted(HeartPrimitiveShape())
            case .diamond:    painted(DiamondPrimitiveShape())
            case .semicircle: painted(SemicirclePrimitiveShape())
            }
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private func painted<S: Shape>(_ shape: S) -> some View {
        ZStack {
            shape.fill(fill)
            if let stroke, strokeWidth > 0 {
                shape.stroke(stroke, style: StrokeStyle(lineWidth: strokeWidth, lineJoin: .round))
            }
        }
    }
}
