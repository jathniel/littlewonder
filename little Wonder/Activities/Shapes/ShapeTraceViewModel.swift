import CoreGraphics
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ShapeTraceViewModel {
    static let eligibleKinds: [ShapeKind] = [
        .circle, .square, .triangle, .star, .heart, .diamond, .hexagon
    ]
    static let rosterSize = 4

    let dotCount = ShapePerimeterSampler.defaultDotCount

    private(set) var shapes: [ShapeKind]
    private(set) var activeIndex: Int = 0
    private(set) var filled: Int = 0
    private(set) var completed: Set<ShapeKind> = []

    private var hasFinishedRound = false

    /// Fires once when the player finishes tracing every shape in the roster.
    var onComplete: (() -> Void)?

    var activeShape: ShapeKind { shapes[activeIndex] }

    init(shapes: [ShapeKind]? = nil) {
        self.shapes = shapes ?? Self.randomRoster()
    }

    static func randomRoster(count: Int = rosterSize) -> [ShapeKind] {
        Array(eligibleKinds.shuffled().prefix(count))
    }

    /// Returns dot samples for the active shape inside the given rect.
    func dots(in rect: CGRect) -> [CGPoint] {
        ShapePerimeterSampler.samples(for: activeShape, in: rect, count: dotCount)
    }

    func selectShape(_ kind: ShapeKind) {
        guard let idx = shapes.firstIndex(of: kind) else { return }
        activeIndex = idx
        filled = 0
    }

    /// Advance the trace cursor past every unfilled dot that lies within `radius`
    /// of the current `touch`. Looping handles fast finger motion that would
    /// otherwise skip past several dots between gesture callbacks.
    func progress(touch: CGPoint, dots: [CGPoint], radius: CGFloat = 36) {
        while filled < dots.count {
            let next = dots[filled]
            guard dragSnapResult(from: touch, to: next, radius: radius).isInRange else { break }
            filled += 1
            if filled >= dots.count {
                completed.insert(activeShape)
                if completed.count >= shapes.count, !hasFinishedRound {
                    hasFinishedRound = true
                    onComplete?()
                }
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
        shapes = Self.randomRoster()
        filled = 0
        completed = []
        activeIndex = 0
        hasFinishedRound = false
    }
}
