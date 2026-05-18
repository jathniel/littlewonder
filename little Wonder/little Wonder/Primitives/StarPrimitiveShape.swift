import SwiftUI

struct StarPrimitiveShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let r = s / 2
        let ri = r * 0.45
        let cx = rect.minX + r
        let cy = rect.minY + r
        var path = Path()
        for i in 0..<10 {
            let radius = i.isMultiple(of: 2) ? r : ri
            let angle = -Double.pi / 2 + Double(i) * Double.pi / 5
            let x = cx + CGFloat(cos(angle)) * radius
            let y = cy + CGFloat(sin(angle)) * radius
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
