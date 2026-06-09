import Foundation
import Testing
@testable import little_Wonder

@MainActor
struct NumberProgressStoreTests {
    private static func makeDefaults() -> UserDefaults {
        let suite = "NumberProgressStoreTests-\(UUID().uuidString)"
        return UserDefaults(suiteName: suite)!
    }

    private static func date(_ iso: String) -> Date {
        try! Date(iso, strategy: .iso8601)
    }

    @Test("Empty defaults produce zeroed counters and a fresh week anchor")
    func defaultsWhenEmpty() {
        let now = Self.date("2026-05-18T12:00:00Z")
        let store = NumberProgressStore(defaults: Self.makeDefaults(), now: { now })

        #expect(store.numbersPlayedThisWeek == 0)
        #expect(store.weeklyCounts.isEmpty)
        #expect(store.lifetimeCounts.isEmpty)
        #expect(store.weekActivity == Array(repeating: false, count: 7))

        let expectedAnchor = Calendar.current.dateInterval(of: .weekOfYear, for: now)?.start
        #expect(store.weekAnchor == expectedAnchor)
    }

    @Test("Recording increments weekly + lifetime and sums across activities")
    func recordingIncrementsCounts() {
        let now = Self.date("2026-05-18T12:00:00Z")
        let store = NumberProgressStore(defaults: Self.makeDefaults(), now: { now })

        store.recordCount()
        store.recordMatch()
        store.recordMatch()
        store.recordOrder()

        #expect(store.weeklyCounts[.count] == 1)
        #expect(store.weeklyCounts[.match] == 2)
        #expect(store.weeklyCounts[.order] == 1)
        #expect(store.lifetimeCounts[.match] == 2)
        #expect(store.numbersPlayedThisWeek == 4)
    }

    @Test("Counters persist across re-init with the same defaults")
    func persistsAcrossInit() {
        let defaults = Self.makeDefaults()
        let now = Self.date("2026-05-18T12:00:00Z")

        let writer = NumberProgressStore(defaults: defaults, now: { now })
        writer.recordCount()
        writer.recordMatch()
        writer.recordOrder()

        let reader = NumberProgressStore(defaults: defaults, now: { now })
        #expect(reader.weeklyCounts[.count] == 1)
        #expect(reader.weeklyCounts[.match] == 1)
        #expect(reader.weeklyCounts[.order] == 1)
        #expect(reader.numbersPlayedThisWeek == 3)
        #expect(reader.weekActivity == writer.weekActivity)
        #expect(reader.weekAnchor == writer.weekAnchor)
    }

    @Test("A new ISO week resets weekly state but preserves lifetime totals")
    func weekRolloverResetsWeeklyOnly() {
        let defaults = Self.makeDefaults()
        let weekOne = Self.date("2026-05-18T12:00:00Z")
        let weekTwo = Self.date("2026-05-26T12:00:00Z")

        let writer = NumberProgressStore(defaults: defaults, now: { weekOne })
        writer.recordMatch()
        writer.recordMatch()
        writer.recordCount()

        let nextWeek = NumberProgressStore(defaults: defaults, now: { weekTwo })
        #expect(nextWeek.weeklyCounts.isEmpty)
        #expect(nextWeek.weekActivity == Array(repeating: false, count: 7))
        #expect(nextWeek.lifetimeCounts[.match] == 2)
        #expect(nextWeek.lifetimeCounts[.count] == 1)
    }

    @Test("Corrupt stored data falls back to defaults without crashing")
    func corruptDataFallsBack() {
        let defaults = Self.makeDefaults()
        defaults.set(Data("not-json".utf8), forKey: "numberProgress.weeklyCounts")
        defaults.set(Data("garbage".utf8), forKey: "numberProgress.lifetimeCounts")
        defaults.set(Data([0xFF, 0xFE]), forKey: "numberProgress.weekActivity")

        let store = NumberProgressStore(defaults: defaults, now: { .now })
        #expect(store.weeklyCounts.isEmpty)
        #expect(store.lifetimeCounts.isEmpty)
        #expect(store.weekActivity == Array(repeating: false, count: 7))
    }
}
