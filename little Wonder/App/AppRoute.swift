import Foundation

enum AppRoute: Hashable, Sendable {
    case topic(TopicID)
    case activity(ActivityID)
    case parentArea
}
