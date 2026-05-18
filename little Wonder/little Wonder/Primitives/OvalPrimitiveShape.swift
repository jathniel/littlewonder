import SwiftUI

struct OvalPrimitiveShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let rx = s / 2
        let ry = s * 0.36
        let cx = rect.minX + s / 2
        let cy = rect.minY + s / 2
        let bounds = CGRect(x: cx - rx, y: cy - ry, width: 2 * rx, height: 2 * ry)
        return Path(ellipseIn: bounds)
    }
}
