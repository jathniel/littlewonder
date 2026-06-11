import Foundation
import Testing
@testable import little_Wonder

@MainActor
struct AnimalProgressStoreTests {
    private static func makeDefaults() -> UserDefaults {
        let suite = "AnimalProgressStoreTests-\(UUID().uuidString)"
        return UserDefaults(suiteName: suite)!
    }

    private static func date(_ iso: String) -> Date {
        try! Date(iso, strategy: .iso8601)
    }

    @Test("Empty defaults produce zeroed counters and a fresh week anchor")
    func defaultsWhenEmpty() {
        let now = Self.date("2026-05-18T12:00:00Z")
        let store = AnimalProgressStore(defaults: Self.makeDefaults(), now: { now })

        #expect(store.animalsPlayedThisWeek == 0)
        #expect(store.weeklyCounts.isEmpty)
        #expect(store.lifetimeCounts.isEmpty)
        #expect(store.weekActivity == Array(repeating: false, count: 7))

        let expectedAnchor = Calendar.current.dateInterval(of: .weekOfYear, for: now)?.start
        #expect(store.weekAnchor == expectedAnchor)
    }

    @Test("Recording increments weekly + lifetime and sums across activities")
    func recordingIncrementsCounts() {
        let now = Self.date("2026-05-18T12:00:00Z")
        let store = AnimalProgressStore(defaults: Self.makeDefaults(), now: { now })

        store.recordMatch()
        store.recordSort()
        store.recordSort()
        store.recordFind()

        #expect(store.weeklyCounts[.match] == 1)
        #expect(store.weeklyCounts[.sort] == 2)
        #expect(store.weeklyCounts[.find] == 1)
        #expect(store.lifetimeCounts[.sort] == 2)
        #expect(store.animalsPlayedThisWeek == 4)
    }

    @Test("Counters persist across re-init with the same defaults")
    func persistsAcrossInit() {
        let defaults = Self.makeDefaults()
        let now = Self.date("2026-05-18T12:00:00Z")

        let writer = AnimalProgressStore(defaults: defaults, now: { now })
        writer.recordMatch()
        writer.recordSort()
        writer.recordFind()

        let reader = AnimalProgressStore(defaults: defaults, now: { now })
        #expect(reader.weeklyCounts[.match] == 1)
        #expect(reader.weeklyCounts[.sort] == 1)
        #expect(reader.weeklyCounts[.find] == 1)
        #expect(reader.animalsPlayedThisWeek == 3)
        #expect(reader.weekActivity == writer.weekActivity)
        #expect(reader.weekAnchor == writer.weekAnchor)
    }

    @Test("A new ISO week resets weekly state but preserves lifetime totals")
    func weekRolloverResetsWeeklyOnly() {
        let defaults = Self.makeDefaults()
        let weekOne = Self.date("2026-05-18T12:00:00Z")
        let weekTwo = Self.date("2026-05-26T12:00:00Z")

        let writer = AnimalProgressStore(defaults: defaults, now: { weekOne })
        writer.recordMatch()
        writer.recordMatch()
        writer.recordFind()

        let nextWeek = AnimalProgressStore(defaults: defaults, now: { weekTwo })
        #expect(nextWeek.weeklyCounts.isEmpty)
        #expect(nextWeek.weekActivity == Array(repeating: false, count: 7))
        #expect(nextWeek.lifetimeCounts[.match] == 2)
        #expect(nextWeek.lifetimeCounts[.find] == 1)
    }

    @Test("Corrupt stored data falls back to defaults without crashing")
    func corruptDataFallsBack() {
        let defaults = Self.makeDefaults()
        defaults.set(Data("not-json".utf8), forKey: "animalProgress.weeklyCounts")
        defaults.set(Data("garbage".utf8), forKey: "animalProgress.lifetimeCounts")
        defaults.set(Data([0xFF, 0xFE]), forKey: "animalProgress.weekActivity")

        let store = AnimalProgressStore(defaults: defaults, now: { .now })
        #expect(store.weeklyCounts.isEmpty)
        #expect(store.lifetimeCounts.isEmpty)
        #expect(store.weekActivity == Array(repeating: false, count: 7))
    }
}
