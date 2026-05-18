import CoreGraphics
import SwiftUI

/// Samples N evenly-spaced points along the perimeter of a `ShapeKind` inside `rect`.
/// The first sample is anchored at the canonical "start" — top center (angle -π/2 for a circle).
enum ShapePerimeterSampler {
    static let defaultDotCount = 18

    static func samples(for kind: ShapeKind, in rect: CGRect, count: Int = defaultDotCount) -> [CGPoint] {
        guard count > 0 else { return [] }
        switch kind {
        case .circle:
            return circle(in: rect, count: count)
        case .square, .rectangle, .diamond:
            return roundedPathSamples(buildSquarePath(in: rect, kind: kind), count: count)
        case .triangle:
            return roundedPathSamples(buildTrianglePath(in: rect), count: count)
        case .star:
            return roundedPathSamples(buildStarPath(in: rect), count: count)
        case .heart:
            return roundedPathSamples(buildHeartPath(in: rect), count: count)
        case .oval:
            return roundedPathSamples(Path(ellipseIn: rect), count: count)
        case .hexagon:
            return roundedPathSamples(buildHexagonPath(in: rect), count: count)
        case .semicircle:
            return roundedPathSamples(buildSemicirclePath(in: rect), count: count)
        }
    }

    private static func circle(in rect: CGRect, count: Int) -> [CGPoint] {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        return (0..<count).map { idx in
            let theta = -.pi / 2 + (2 * .pi) * Double(idx) / Double(count)
            return CGPoint(
                x: center.x + radius * CGFloat(cos(theta)),
                y: center.y + radius * CGFloat(sin(theta))
            )
        }
    }

    /// Sample a closed path by walking trimmed sub-paths at uniform `t` fractions.
    private static func roundedPathSamples(_ path: Path, count: Int) -> [CGPoint] {
        guard count > 0 else { return [] }
        var result: [CGPoint] = []
        result.reserveCapacity(count)
        for idx in 0..<count {
            let t = CGFloat(idx) / CGFloat(count)
            let nudge = max(t - 0.0001, 0)
            let tiny = path.trimmedPath(from: nudge, to: min(nudge + 0.0005, 1))
            let bbox = tiny.boundingRect
            if bbox.isEmpty || bbox.isInfinite || bbox.isNull {
                result.append(CGPoint(x: path.boundingRect.midX, y: path.boundingRect.midY))
            } else {
                result.append(CGPoint(x: bbox.midX, y: bbox.midY))
            }
        }
        return result
    }

    // MARK: - Path builders

    private static func buildSquarePath(in rect: CGRect, kind: ShapeKind) -> Path {
        let s = min(rect.width, rect.height)
        switch kind {
        case .rectangle:
            let bounds = CGRect(
                x: rect.minX,
                y: rect.minY + s * 0.18,
                width: s,
                height: s * 0.64
            )
            return Path(roundedRect: bounds, cornerRadius: s * 0.06, style: .continuous)
        case .diamond:
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.closeSubpath()
            return path
        default:
            let bounds = CGRect(x: rect.minX, y: rect.minY, width: s, height: s)
            return Path(roundedRect: bounds, cornerRadius: s * 0.08, style: .continuous)
        }
    }

    private static func buildTrianglePath(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + s / 2, y: rect.minY + s * 0.04))
        path.addLine(to: CGPoint(x: rect.minX + s, y: rect.minY + s * 0.96))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + s * 0.96))
        path.closeSubpath()
        return path
    }

    private static func buildHexagonPath(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let r = s / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        for i in 0..<6 {
            let theta = -.pi / 2 + .pi / 3 * Double(i)
            let pt = CGPoint(x: center.x + r * CGFloat(cos(theta)), y: center.y + r * CGFloat(sin(theta)))
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }

    private static func buildStarPath(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = s / 2
        let inner = outer * 0.45
        var path = Path()
        for i in 0..<10 {
            let theta = -.pi / 2 + .pi / 5 * Double(i)
            let r = i.isMultiple(of: 2) ? outer : inner
            let pt = CGPoint(x: center.x + r * CGFloat(cos(theta)), y: center.y + r * CGFloat(sin(theta)))
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }

    private static func buildHeartPath(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        var path = Path()
        let top = CGPoint(x: rect.midX, y: rect.minY + s * 0.30)
        path.move(to: top)
        path.addCurve(
            to: CGPoint(x: rect.minX + s * 0.04, y: rect.minY + s * 0.36),
            control1: CGPoint(x: rect.minX + s * 0.30, y: rect.minY),
            control2: CGPoint(x: rect.minX + s * 0.02, y: rect.minY + s * 0.12)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY + s * 0.94),
            control1: CGPoint(x: rect.minX + s * 0.06, y: rect.minY + s * 0.66),
            control2: CGPoint(x: rect.minX + s * 0.40, y: rect.minY + s * 0.80)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + s * 0.96, y: rect.minY + s * 0.36),
            control1: CGPoint(x: rect.minX + s * 0.60, y: rect.minY + s * 0.80),
            control2: CGPoint(x: rect.minX + s * 0.94, y: rect.minY + s * 0.66)
        )
        path.addCurve(
            to: top,
            control1: CGPoint(x: rect.minX + s * 0.98, y: rect.minY + s * 0.12),
            control2: CGPoint(x: rect.minX + s * 0.70, y: rect.minY)
        )
        path.closeSubpath()
        return path
    }

    private static func buildSemicirclePath(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.minY + s)
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + s))
        path.addArc(
            center: center,
            radius: s / 2,
            startAngle: .degrees(180),
            endAngle: .degrees(360),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}
