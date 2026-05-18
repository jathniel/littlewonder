import CoreGraphics
import Foundation
import Testing
@testable import little_Wonder

struct ShapePerimeterSamplerTests {
    private static let rect = CGRect(x: 0, y: 0, width: 200, height: 200)

    @Test("Default count is 18 dots for every traceable kind",
          arguments: [ShapeKind.circle, .square, .triangle, .star, .heart])
    func defaultCount(_ kind: ShapeKind) {
        let dots = ShapePerimeterSampler.samples(for: kind, in: Self.rect)
        #expect(dots.count == 18)
    }

    @Test("Circle first sample anchored at angle -π/2 (top center)")
    func circleFirstAnchor() {
        let dots = ShapePerimeterSampler.samples(for: .circle, in: Self.rect)
        let first = try? #require(dots.first)
        // Expect (midX, minY) within tolerance.
        if let first {
            #expect(abs(first.x - Self.rect.midX) < 0.001)
            #expect(abs(first.y - Self.rect.minY) < 0.001)
        }
    }

    @Test("Circle dots progress monotonically by angle from -π/2")
    func circleMonotonic() {
        let dots = ShapePerimeterSampler.samples(for: .circle, in: Self.rect)
        let center = CGPoint(x: Self.rect.midX, y: Self.rect.midY)
        var lastTheta = -Double.pi / 2
        for (idx, dot) in dots.enumerated() {
            let theta = atan2(Double(dot.y - center.y), Double(dot.x - center.x))
            let normalized = normalize(theta, start: -.pi / 2)
            if idx > 0 {
                #expect(normalized >= normalize(lastTheta, start: -.pi / 2) - 1e-6)
            }
            lastTheta = theta
        }
    }

    private func normalize(_ theta: Double, start: Double) -> Double {
        var delta = theta - start
        while delta < 0 { delta += 2 * .pi }
        while delta >= 2 * .pi { delta -= 2 * .pi }
        return delta
    }
}
