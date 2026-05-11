import SwiftUI

struct TrianglePrimitiveShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let x = rect.minX
        let y = rect.minY
        var path = Path()
        path.move(to: CGPoint(x: x + s / 2, y: y + s * 0.04))
        path.addLine(to: CGPoint(x: x + s, y: y + s * 0.96))
        path.addLine(to: CGPoint(x: x, y: y + s * 0.96))
        path.closeSubpath()
        return path
    }
}
