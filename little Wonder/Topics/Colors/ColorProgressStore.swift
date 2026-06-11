import Foundation

/// Tracks per-activity weekly and lifetime counts for the Colours Room.
typealias ColorProgressStore = TopicProgressStore<ColorActivityID>

extension ColorActivityID: TopicActivity {
    static var persistenceKeyPrefix: String { "colorProgress" }
}

extension TopicProgressStore where Activity == ColorActivityID {
    /// Surfaced for the Colour Room weekly card — total scored plays this week.
    var colorsPlayedThisWeek: Int { playedThisWeek }

    func recordMatch() { record(.match) }
    func recordSort() { record(.sort) }
    func recordFind() { record(.find) }
    func recordMix() { record(.mix) }
}
