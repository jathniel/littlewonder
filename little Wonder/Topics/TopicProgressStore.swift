import Foundation
import Observation

/// Tracks per-activity weekly and lifetime counts for a topic room.
///
/// Persisted to `UserDefaults` under `Activity.persistenceKeyPrefix`. Weekly counters
/// auto-reset when a new ISO week is detected (on load and lazily on every record),
/// while lifetime counters accumulate forever.
@MainActor
@Observable
final class TopicProgressStore<Activity: TopicActivity> {
    private(set) var weeklyCounts: [Activity: Int] {
        didSet { encode(Self.rawKeyed(weeklyCounts), forKey: Self.weeklyCountsKey) }
    }
    private(set) var lifetimeCounts: [Activity: Int] {
        didSet { encode(Self.rawKeyed(lifetimeCounts), forKey: Self.lifetimeCountsKey) }
    }
    /// Sunday … Saturday — `true` when any activity completed that day.
    private(set) var weekActivity: [Bool] {
        didSet { encode(weekActivity, forKey: Self.weekActivityKey) }
    }
    /// Start-of-week date used to detect when weekly state should reset.
    private(set) var weekAnchor: Date {
        didSet { defaults.set(weekAnchor.timeIntervalSinceReferenceDate, forKey: Self.weekAnchorKey) }
    }

    /// Total scored plays this week across all activities — surfaced on room weekly cards.
    var playedThisWeek: Int { weeklyCounts.values.reduce(0, +) }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let calendar: Calendar

    init(
        defaults: UserDefaults = .standard,
        now: @escaping () -> Date = { .now },
        calendar: Calendar = .current
    ) {
        self.defaults = defaults
        self.now = now
        self.calendar = calendar

        let storedWeekly: [Activity: Int] =
            Self.decode([String: Int].self, forKey: Self.weeklyCountsKey, from: defaults)
                .map(Self.activityKeyed) ?? [:]
        let storedLifetime: [Activity: Int] =
            Self.decode([String: Int].self, forKey: Self.lifetimeCountsKey, from: defaults)
                .map(Self.activityKeyed) ?? [:]
        let storedActivity: [Bool] =
            Self.decode([Bool].self, forKey: Self.weekActivityKey, from: defaults)
                .flatMap { $0.count == 7 ? $0 : nil }
                ?? Array(repeating: false, count: 7)
        let storedAnchor: Date? = {
            let raw = defaults.object(forKey: Self.weekAnchorKey) as? Double
            return raw.map { Date(timeIntervalSinceReferenceDate: $0) }
        }()

        self.weeklyCounts = storedWeekly
        self.lifetimeCounts = storedLifetime
        self.weekActivity = storedActivity
        let resolvedAnchor = storedAnchor ?? Self.startOfWeek(for: now(), calendar: calendar)
        self.weekAnchor = resolvedAnchor

        // `didSet` does not run during `init`, so persist the anchor explicitly
        // on first launch — otherwise the next launch would re-default and the
        // rollover check would never fire across week boundaries.
        if storedAnchor == nil {
            defaults.set(resolvedAnchor.timeIntervalSinceReferenceDate, forKey: Self.weekAnchorKey)
        }

        rolloverIfNeeded()
    }

    // MARK: - Recording

    func record(_ activity: Activity) {
        rolloverIfNeeded()
        weeklyCounts[activity, default: 0] += 1
        lifetimeCounts[activity, default: 0] += 1
        markToday()
    }

    private func markToday() {
        let weekday = calendar.component(.weekday, from: now()) - 1
        guard weekActivity.indices.contains(weekday) else { return }
        guard weekActivity[weekday] == false else { return }
        weekActivity[weekday] = true
    }

    // MARK: - Week rollover

    private func rolloverIfNeeded() {
        let current = Self.startOfWeek(for: now(), calendar: calendar)
        guard current != weekAnchor else { return }
        weeklyCounts = [:]
        weekActivity = Array(repeating: false, count: 7)
        weekAnchor = current
    }

    private static func startOfWeek(for date: Date, calendar: Calendar) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }

    // MARK: - Persistence helpers

    private static var weeklyCountsKey: String { Activity.persistenceKeyPrefix + ".weeklyCounts" }
    private static var lifetimeCountsKey: String { Activity.persistenceKeyPrefix + ".lifetimeCounts" }
    private static var weekActivityKey: String { Activity.persistenceKeyPrefix + ".weekActivity" }
    private static var weekAnchorKey: String { Activity.persistenceKeyPrefix + ".weekAnchor" }

    private func encode<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func decode<T: Decodable>(_ type: T.Type, forKey key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private static func rawKeyed(_ counts: [Activity: Int]) -> [String: Int] {
        counts.reduce(into: [:]) { $0[$1.key.rawValue] = $1.value }
    }

    private static func activityKeyed(_ counts: [String: Int]) -> [Activity: Int] {
        counts.reduce(into: [:]) { partial, pair in
            guard let id = Activity(rawValue: pair.key) else { return }
            partial[id] = pair.value
        }
    }
}
