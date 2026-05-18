import SwiftUI

struct HeartPrimitiveShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let x = rect.minX
        let y = rect.minY
        var path = Path()
        path.move(to: CGPoint(x: x + s / 2, y: y + s * 0.86))
        path.addCurve(
            to: CGPoint(x: x + s / 2, y: y + s * 0.34),
            control1: CGPoint(x: x + s * 0.05, y: y + s * 0.55),
            control2: CGPoint(x: x + s * 0.05, y: y + s * 0.20)
        )
        path.addCurve(
            to: CGPoint(x: x + s / 2, y: y + s * 0.86),
            control1: CGPoint(x: x + s * 0.95, y: y + s * 0.20),
            control2: CGPoint(x: x + s * 0.95, y: y + s * 0.55)
        )
        path.closeSubpath()
        return path
    }
}
