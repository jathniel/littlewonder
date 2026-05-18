import SwiftUI

struct RectanglePrimitiveShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let bounds = CGRect(
            x: rect.minX,
            y: rect.minY + s * 0.18,
            width: s,
            height: s * 0.64
        )
        return Path(roundedRect: bounds, cornerRadius: s * 0.06, style: .continuous)
    }
}
