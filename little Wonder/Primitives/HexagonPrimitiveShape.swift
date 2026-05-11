import SwiftUI

struct HexagonPrimitiveShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let r = s / 2
        let cx = rect.minX + r
        let cy = rect.minY + r
        var path = Path()
        for i in 0..<6 {
            let angle = -Double.pi / 2 + Double(i) * Double.pi / 3
            let x = cx + CGFloat(cos(angle)) * r
            let y = cy + CGFloat(sin(angle)) * r
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}
