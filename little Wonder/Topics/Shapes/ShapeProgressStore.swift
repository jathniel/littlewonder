import Foundation
import Observation
import SwiftUI

/// Tracks per-activity weekly and lifetime counts for the Shape Room.
///
/// Persisted to `UserDefaults`. Weekly counters auto-reset when a new ISO week
/// is detected (on load and lazily on every record), while lifetime counters
/// accumulate forever.
@MainActor
@Observable
final class ShapeProgressStore {
    private(set) var weeklyCounts: [ShapeActivityID: Int] {
        didSet { encode(weeklyCounts.mappedByRawValue, forKey: Keys.weeklyCounts) }
    }
    private(set) var lifetimeCounts: [ShapeActivityID: Int] {
        didSet { encode(lifetimeCounts.mappedByRawValue, forKey: Keys.lifetimeCounts) }
    }
    /// Sunday … Saturday — `true` when any activity completed that day.
    private(set) var weekActivity: [Bool] {
        didSet { encode(weekActivity, forKey: Keys.weekActivity) }
    }
    /// Start-of-week date used to detect when weekly state should reset.
    private(set) var weekAnchor: Date {
        didSet { defaults.set(weekAnchor.timeIntervalSinceReferenceDate, forKey: Keys.weekAnchor) }
    }

    /// Convenience surfaced for the Shape Room weekly card.
    var matchesMadeThisWeek: Int { weeklyCounts[.match, default: 0] }

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

        let storedWeekly: [ShapeActivityID: Int] =
            Self.decode([String: Int].self, forKey: Keys.weeklyCounts, from: defaults)?
                .mappedByActivityID() ?? [:]
        let storedLifetime: [ShapeActivityID: Int] =
            Self.decode([String: Int].self, forKey: Keys.lifetimeCounts, from: defaults)?
                .mappedByActivityID() ?? [:]
        let storedActivity: [Bool] =
            Self.decode([Bool].self, forKey: Keys.weekActivity, from: defaults)
                .flatMap { $0.count == 7 ? $0 : nil }
                ?? Array(repeating: false, count: 7)
        let storedAnchor: Date? = {
            let raw = defaults.object(forKey: Keys.weekAnchor) as? Double
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
            defaults.set(resolvedAnchor.timeIntervalSinceReferenceDate, forKey: Keys.weekAnchor)
        }

        rolloverIfNeeded()
    }

    // MARK: - Recording

    func recordMatch() { record(.match) }
    func recordSort()  { record(.sort)  }
    func recordTrace() { record(.trace) }
    func recordBuild() { record(.build) }

    private func record(_ activity: ShapeActivityID) {
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

    private func encode<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func decode<T: Decodable>(_ type: T.Type, forKey key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private enum Keys {
        static let weeklyCounts = "shapeProgress.weeklyCounts"
        static let lifetimeCounts = "shapeProgress.lifetimeCounts"
        static let weekActivity = "shapeProgress.weekActivity"
        static let weekAnchor = "shapeProgress.weekAnchor"
    }
}

private extension Dictionary where Key == ShapeActivityID, Value == Int {
    var mappedByRawValue: [String: Int] {
        reduce(into: [:]) { $0[$1.key.rawValue] = $1.value }
    }
}

private extension Dictionary where Key == String, Value == Int {
    func mappedByActivityID() -> [ShapeActivityID: Int] {
        reduce(into: [:]) { partial, pair in
            guard let id = ShapeActivityID(rawValue: pair.key) else { return }
            partial[id] = pair.value
        }
    }
}
