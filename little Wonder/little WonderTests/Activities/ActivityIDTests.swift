import Testing
@testable import little_Wonder

struct ActivityIDTests {
    @Test("Raw value round-trips for every activity", arguments: ActivityID.allCases)
    func rawValueRoundTrips(_ activity: ActivityID) throws {
        let decoded = try #require(ActivityID(rawValue: activity.rawValue))
        #expect(decoded == activity)
    }

    @Test("Identifier equals raw value", arguments: ActivityID.allCases)
    func idMatchesRawValue(_ activity: ActivityID) {
        #expect(activity.id == activity.rawValue)
    }
}
