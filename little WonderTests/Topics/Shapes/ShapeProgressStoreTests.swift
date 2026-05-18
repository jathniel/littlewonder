import Foundation
import Testing
@testable import little_Wonder

@MainActor
struct ShapeProgressStoreTests {
    /// Each test gets a fresh, isolated suite so parallel execution never bleeds
    /// state across cases.
    private static func makeDefaults() -> UserDefaults {
        let suite = "ShapeProgressStoreTests-\(UUID().uuidString)"
        return UserDefaults(suiteName: suite)!
    }

    private static func date(_ iso: String) -> Date {
        try! Date(iso, strategy: .iso8601)
    }

    // MARK: - Defaults

    @Test("Empty defaults produce zeroed counters and a fresh week anchor")
    func defaultsWhenEmpty() {
        let now = Self.date("2026-05-18T12:00:00Z")
        let store = ShapeProgressStore(defaults: Self.makeDefaults(), now: { now })

        #expect(store.matchesMadeThisWeek == 0)
        #expect(store.weeklyCounts.isEmpty)
        #expect(store.lifetimeCounts.isEmpty)
        #expect(store.weekActivity == Array(repeating: false, count: 7))

        let expectedAnchor = Calendar.current.dateInterval(of: .weekOfYear, for: now)?.start
        #expect(store.weekAnchor == expectedAnchor)
    }

    // MARK: - Recording

    @Test("Recording increments both weekly and lifetime counts")
    func recordingIncrementsCounts() {
        let now = Self.date("2026-05-18T12:00:00Z")
        let store = ShapeProgressStore(defaults: Self.makeDefaults(), now: { now })

        store.recordMatch()
        store.recordMatch()
        store.recordSort()

        #expect(store.weeklyCounts[.match] == 2)
        #expect(store.weeklyCounts[.sort] == 1)
        #expect(store.lifetimeCounts[.match] == 2)
        #expect(store.lifetimeCounts[.sort] == 1)
        #expect(store.matchesMadeThisWeek == 2)
    }

    @Test(
        "matchesMadeThisWeek reflects weeklyCounts[.match] for any count",
        arguments: [0, 1, 5, 42]
    )
    func matchesMadeMirrorsWeeklyCount(_ count: Int) {
        let now = Self.date("2026-05-18T12:00:00Z")
        let store = ShapeProgressStore(defaults: Self.makeDefaults(), now: { now })
        for _ in 0..<count { store.recordMatch() }
        #expect(store.matchesMadeThisWeek == count)
    }

    @Test("Recording marks today's slot in weekActivity")
    func recordingMarksToday() {
        // 2026-05-18 is a Monday → weekday index 1 (Sunday=0).
        let now = Self.date("2026-05-18T12:00:00Z")
        let store = ShapeProgressStore(defaults: Self.makeDefaults(), now: { now })

        store.recordTrace()

        let weekday = Calendar.current.component(.weekday, from: now) - 1
        #expect(store.weekActivity[weekday] == true)
        #expect(store.weekActivity.filter { $0 }.count == 1)
    }

    // MARK: - Persistence round-trip

    @Test("Counters persist across re-init with the same defaults")
    func persistsAcrossInit() {
        let defaults = Self.makeDefaults()
        let now = Self.date("2026-05-18T12:00:00Z")

        let writer = ShapeProgressStore(defaults: defaults, now: { now })
        writer.recordMatch()
        writer.recordMatch()
        writer.recordSort()
        writer.recordTrace()
        writer.recordBuild()

        let reader = ShapeProgressStore(defaults: defaults, now: { now })
        #expect(reader.weeklyCounts[.match] == 2)
        #expect(reader.weeklyCounts[.sort] == 1)
        #expect(reader.weeklyCounts[.trace] == 1)
        #expect(reader.weeklyCounts[.build] == 1)
        #expect(reader.lifetimeCounts[.match] == 2)
        #expect(reader.lifetimeCounts[.sort] == 1)
        #expect(reader.lifetimeCounts[.trace] == 1)
        #expect(reader.lifetimeCounts[.build] == 1)
        #expect(reader.matchesMadeThisWeek == 2)
        #expect(reader.weekActivity == writer.weekActivity)
        #expect(reader.weekAnchor == writer.weekAnchor)
    }

    // MARK: - Week rollover

    @Test("A new ISO week resets weekly state but preserves lifetime totals")
    func weekRolloverResetsWeeklyOnly() {
        let defaults = Self.makeDefaults()
        let weekOne = Self.date("2026-05-18T12:00:00Z")
        let weekTwo = Self.date("2026-05-26T12:00:00Z")  // following week

        let writer = ShapeProgressStore(defaults: defaults, now: { weekOne })
        writer.recordMatch()
        writer.recordMatch()
        writer.recordSort()

        // Re-init in the following week: load triggers rollover.
        let nextWeek = ShapeProgressStore(defaults: defaults, now: { weekTwo })
        #expect(nextWeek.weeklyCounts.isEmpty)
        #expect(nextWeek.weekActivity == Array(repeating: false, count: 7))
        #expect(nextWeek.lifetimeCounts[.match] == 2)
        #expect(nextWeek.lifetimeCounts[.sort] == 1)

        // Recording in the new week accumulates into the fresh weekly bucket
        // while continuing to grow lifetime totals.
        nextWeek.recordMatch()
        #expect(nextWeek.weeklyCounts[.match] == 1)
        #expect(nextWeek.lifetimeCounts[.match] == 3)
    }

    @Test("Same-week re-init does not reset counters")
    func sameWeekDoesNotReset() {
        let defaults = Self.makeDefaults()
        let monday = Self.date("2026-05-18T09:00:00Z")
        let thursday = Self.date("2026-05-21T09:00:00Z")

        let writer = ShapeProgressStore(defaults: defaults, now: { monday })
        writer.recordMatch()

        let later = ShapeProgressStore(defaults: defaults, now: { thursday })
        #expect(later.weeklyCounts[.match] == 1)
        #expect(later.lifetimeCounts[.match] == 1)
    }

    @Test("Rollover triggers lazily on the next record call after week change")
    func rolloverLazyOnRecord() {
        let defaults = Self.makeDefaults()
        let weekOne = Self.date("2026-05-18T12:00:00Z")
        var clock = weekOne

        let store = ShapeProgressStore(defaults: defaults, now: { clock })
        store.recordMatch()
        #expect(store.weeklyCounts[.match] == 1)

        // Advance the clock past the week boundary without re-initializing.
        clock = Self.date("2026-05-26T12:00:00Z")
        store.recordSort()

        // Weekly counts were reset before the sort was recorded.
        #expect(store.weeklyCounts[.match, default: 0] == 0)
        #expect(store.weeklyCounts[.sort] == 1)
        #expect(store.lifetimeCounts[.match] == 1)
        #expect(store.lifetimeCounts[.sort] == 1)
    }

    // MARK: - Robustness

    @Test("Corrupt stored data falls back to defaults without crashing")
    func corruptDataFallsBack() {
        let defaults = Self.makeDefaults()
        defaults.set(Data("not-json".utf8), forKey: "shapeProgress.weeklyCounts")
        defaults.set(Data("garbage".utf8), forKey: "shapeProgress.lifetimeCounts")
        defaults.set(Data([0xFF, 0xFE]), forKey: "shapeProgress.weekActivity")

        let store = ShapeProgressStore(defaults: defaults, now: { .now })
        #expect(store.weeklyCounts.isEmpty)
        #expect(store.lifetimeCounts.isEmpty)
        #expect(store.weekActivity == Array(repeating: false, count: 7))
    }

    @Test("Unknown activity keys in stored data are silently dropped")
    func unknownActivityKeysDropped() {
        let defaults = Self.makeDefaults()
        let payload = try! JSONEncoder().encode(["match": 5, "obsolete-activity": 99])
        defaults.set(payload, forKey: "shapeProgress.lifetimeCounts")

        let store = ShapeProgressStore(defaults: defaults, now: { .now })
        #expect(store.lifetimeCounts[.match] == 5)
        #expect(store.lifetimeCounts.count == 1)
    }
}
