import Foundation

/// Tracks per-activity weekly and lifetime counts for the Animals Room.
typealias AnimalProgressStore = TopicProgressStore<AnimalActivityID>

extension AnimalActivityID: TopicActivity {
    static var persistenceKeyPrefix: String { "animalProgress" }
}

extension TopicProgressStore where Activity == AnimalActivityID {
    /// Surfaced for the Animal Room weekly card — total scored plays this week.
    var animalsPlayedThisWeek: Int { playedThisWeek }

    func recordMatch() { record(.match) }
    func recordSort() { record(.sort) }
    func recordFind() { record(.find) }
}
