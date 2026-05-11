import Testing
@testable import little_Wonder

struct PaceModeTests {
    @Test("Raw value round-trips for every mode", arguments: PaceMode.allCases)
    func rawValueRoundTrips(_ mode: PaceMode) throws {
        let decoded = try #require(PaceMode(rawValue: mode.rawValue))
        #expect(decoded == mode)
    }

    @Test("Identifier equals raw value", arguments: PaceMode.allCases)
    func idMatchesRawValue(_ mode: PaceMode) {
        #expect(mode.id == mode.rawValue)
    }

    @Test(
        "pace resolves to the matching static pace",
        arguments: zip(
            [PaceMode.slow, .playful] as [PaceMode],
            [Pace.slow, .playful] as [Pace]
        )
    )
    func paceMatches(_ mode: PaceMode, _ expected: Pace) {
        #expect(mode.pace == expected)
    }

    /// Sanity check that pace durations are strictly ordered: every fast duration
    /// is shorter than its base, which is shorter than its long counterpart.
    @Test("Pace durations are strictly ordered", arguments: PaceMode.allCases)
    func paceDurationsAreOrdered(_ mode: PaceMode) {
        let pace = mode.pace
        #expect(pace.fast < pace.base)
        #expect(pace.base < pace.long)
    }
}
