import CoreGraphics
import Testing
@testable import little_Wonder

struct DragSnapHelpersTests {
    struct SnapScenario: Sendable, CustomTestStringConvertible {
        let point: CGPoint
        let target: CGPoint
        let radius: CGFloat
        let expectedDistance: CGFloat
        let expectedInRange: Bool

        var testDescription: String {
            "point=(\(point.x),\(point.y)) target=(\(target.x),\(target.y)) r=\(radius)"
        }
    }

    /// Mixed scenarios: zero distance, axis-aligned distances, 3-4-5 triangle, and
    /// points exactly on / just outside the snap radius boundary.
    private static let scenarios: [SnapScenario] = [
        .init(point: .zero, target: .zero, radius: 60, expectedDistance: 0, expectedInRange: true),
        .init(point: .init(x: 10, y: 0), target: .zero, radius: 60, expectedDistance: 10, expectedInRange: true),
        .init(point: .init(x: 0, y: 10), target: .zero, radius: 60, expectedDistance: 10, expectedInRange: true),
        .init(point: .init(x: 3, y: 4), target: .zero, radius: 60, expectedDistance: 5, expectedInRange: true),
        .init(point: .init(x: 60, y: 0), target: .zero, radius: 60, expectedDistance: 60, expectedInRange: true),
        .init(point: .init(x: 60.01, y: 0), target: .zero, radius: 60, expectedDistance: 60.01, expectedInRange: false),
        .init(point: .init(x: 100, y: 0), target: .zero, radius: 60, expectedDistance: 100, expectedInRange: false),
        .init(point: .init(x: 13, y: 14), target: .init(x: 10, y: 10), radius: 5, expectedDistance: 5, expectedInRange: true),
        .init(point: .init(x: -3, y: -4), target: .zero, radius: 5, expectedDistance: 5, expectedInRange: true),
        .init(point: .init(x: 30, y: 40), target: .zero, radius: 49.99, expectedDistance: 50, expectedInRange: false)
    ]

    @Test("dragSnapResult reports correct distance and range", arguments: Self.scenarios)
    func dragSnapResult(_ scenario: SnapScenario) {
        let result = little_Wonder.dragSnapResult(
            from: scenario.point,
            to: scenario.target,
            radius: scenario.radius
        )
        #expect(abs(result.distance - scenario.expectedDistance) < 0.0001)
        #expect(result.isInRange == scenario.expectedInRange)
    }

    @Test("Default snap radius is 60 points")
    func defaultRadius() {
        #expect(defaultSnapRadius == 60)
    }

    @Test(
        "Default radius matches when omitted",
        arguments: [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 59, y: 0),
            CGPoint(x: 60, y: 0),
            CGPoint(x: 61, y: 0)
        ]
    )
    func defaultRadiusIsApplied(_ point: CGPoint) {
        let withDefault = little_Wonder.dragSnapResult(from: point, to: .zero)
        let withExplicit = little_Wonder.dragSnapResult(from: point, to: .zero, radius: defaultSnapRadius)
        #expect(withDefault == withExplicit)
    }
}
