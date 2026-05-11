import CoreGraphics
import Foundation

/// Snap radius shared by FirstTouch and ShapeMatch, in points.
let defaultSnapRadius: CGFloat = 60

struct DragSnapResult: Equatable, Sendable {
    let distance: CGFloat
    let isInRange: Bool
}

/// Pure helper: tests whether `point` is within `radius` of `target`.
func dragSnapResult(
    from point: CGPoint,
    to target: CGPoint,
    radius: CGFloat = defaultSnapRadius
) -> DragSnapResult {
    let dx = point.x - target.x
    let dy = point.y - target.y
    let distance = sqrt(dx * dx + dy * dy)
    return DragSnapResult(distance: distance, isInRange: distance <= radius)
}
