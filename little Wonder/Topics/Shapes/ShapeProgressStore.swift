import Foundation

/// Tracks per-activity weekly and lifetime counts for the Shape Room.
typealias ShapeProgressStore = TopicProgressStore<ShapeActivityID>

extension ShapeActivityID: TopicActivity {
    static var persistenceKeyPrefix: String { "shapeProgress" }
}

extension TopicProgressStore where Activity == ShapeActivityID {
    /// Convenience surfaced for the Shape Room weekly card.
    var matchesMadeThisWeek: Int { weeklyCounts[.match, default: 0] }

    func recordMatch() { record(.match) }
    func recordSort()  { record(.sort)  }
    func recordTrace() { record(.trace) }
    func recordBuild() { record(.build) }
}
