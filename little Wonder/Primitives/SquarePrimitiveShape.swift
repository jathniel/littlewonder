import SwiftUI

struct SquarePrimitiveShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let bounds = CGRect(x: rect.minX, y: rect.minY, width: s, height: s)
        return Path(roundedRect: bounds, cornerRadius: s * 0.08, style: .continuous)
    }
}
