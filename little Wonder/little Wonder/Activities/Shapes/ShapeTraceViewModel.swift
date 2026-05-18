import CoreGraphics
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ShapeTraceViewModel {
    let shapes: [ShapeKind] = [.circle, .square, .triangle, .star, .heart]
    let dotCount = ShapePerimeterSampler.defaultDotCount

    private(set) var activeIndex: Int = 0
    private(set) var filled: Int = 0
    private(set) var completed: Set<ShapeKind> = []

    var activeShape: ShapeKind { shapes[activeIndex] }

    /// Returns dot samples for the active shape inside the given rect.
    func dots(in rect: CGRect) -> [CGPoint] {
        ShapePerimeterSampler.samples(for: activeShape, in: rect, count: dotCount)
    }

    func selectShape(_ kind: ShapeKind) {
        guard let idx = shapes.firstIndex(of: kind) else { return }
        activeIndex = idx
        filled = 0
    }

    /// Advance one dot if `touch` is within `radius` of the next target dot.
    func progress(touch: CGPoint, dots: [CGPoint], radius: CGFloat = 24) {
        guard filled < dots.count else { return }
        let next = dots[filled]
        if dragSnapResult(from: touch, to: next, radius: radius).isInRange {
            filled += 1
            if filled >= dots.count {
                completed.insert(activeShape)
            }
        }
    }

    func advanceShape() {
        guard filled >= dotCount else { return }
        if activeIndex + 1 < shapes.count {
            activeIndex += 1
        }
        filled = 0
    }

    func reset() {
        filled = 0
        completed = []
        activeIndex = 0
    }
}
