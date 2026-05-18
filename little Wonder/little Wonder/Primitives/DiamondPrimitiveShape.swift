import SwiftUI

struct DiamondPrimitiveShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let x = rect.minX
        let y = rect.minY
        var path = Path()
        path.move(to: CGPoint(x: x + s / 2, y: y))
        path.addLine(to: CGPoint(x: x + s, y: y + s / 2))
        path.addLine(to: CGPoint(x: x + s / 2, y: y + s))
        path.addLine(to: CGPoint(x: x, y: y + s / 2))
        path.closeSubpath()
        return path
    }
}
