import Foundation

/// An activity identifier whose topic-room progress is tracked by `TopicProgressStore`.
protocol TopicActivity: RawRepresentable<String>, Hashable, Sendable {
    /// Prefix for the `UserDefaults` keys backing the topic's progress, e.g. "shapeProgress".
    static var persistenceKeyPrefix: String { get }
}
