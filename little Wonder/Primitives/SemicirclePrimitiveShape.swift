import SwiftUI

struct SemicirclePrimitiveShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let r = s / 2
        let cx = rect.minX + r
        let cy = rect.minY + s * 0.7
        var path = Path()
        path.move(to: CGPoint(x: cx - r, y: cy))
        // Upper semicircle from leftmost to rightmost over the top.
        path.addArc(
            center: CGPoint(x: cx, y: cy),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(360),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}
