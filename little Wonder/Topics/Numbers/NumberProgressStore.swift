import Foundation

/// Tracks per-activity weekly and lifetime counts for the Number Room.
typealias NumberProgressStore = TopicProgressStore<NumberActivityID>

extension NumberActivityID: TopicActivity {
    static var persistenceKeyPrefix: String { "numberProgress" }
}

extension TopicProgressStore where Activity == NumberActivityID {
    /// Surfaced for the Number Room weekly card — total scored plays this week.
    var numbersPlayedThisWeek: Int { playedThisWeek }

    func recordCount() { record(.count) }
    func recordMatch() { record(.match) }
    func recordOrder() { record(.order) }
}
