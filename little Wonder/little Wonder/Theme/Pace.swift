import SwiftUI

struct Pace: Equatable {
    let fast: Duration
    let base: Duration
    let long: Duration
    let curve: UnitCurve
}

extension Pace {
    static let slow = Pace(
        fast: .milliseconds(360),
        base: .milliseconds(720),
        long: .milliseconds(1400),
        curve: .bezier(
            startControlPoint: .init(x: 0.22, y: 0.61),
            endControlPoint: .init(x: 0.36, y: 1.0)
        )
    )

    static let playful = Pace(
        fast: .milliseconds(180),
        base: .milliseconds(360),
        long: .milliseconds(720),
        curve: .bezier(
            startControlPoint: .init(x: 0.34, y: 1.56),
            endControlPoint: .init(x: 0.64, y: 1.0)
        )
    )

    func animation(_ duration: Duration) -> Animation {
        .timingCurve(curve, duration: duration.asSeconds)
    }

    var fastAnimation: Animation { animation(fast) }
    var baseAnimation: Animation { animation(base) }
    var longAnimation: Animation { animation(long) }
}

private extension Duration {
    var asSeconds: TimeInterval {
        let parts = components
        return TimeInterval(parts.seconds) + TimeInterval(parts.attoseconds) / 1e18
    }
}
