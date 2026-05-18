import Testing
@testable import little_Wonder

struct TopicIDTests {
    @Test("Raw value round-trips for every topic", arguments: TopicID.allCases)
    func rawValueRoundTrips(_ topic: TopicID) throws {
        let decoded = try #require(TopicID(rawValue: topic.rawValue))
        #expect(decoded == topic)
    }

    @Test("Identifier equals raw value", arguments: TopicID.allCases)
    func idMatchesRawValue(_ topic: TopicID) {
        #expect(topic.id == topic.rawValue)
    }

    /// Cartesian product: every topic must resolve a colour in every palette mode
    /// — guards against missing keypath wiring after palette changes.
    @Test(
        "Accent keypath resolves in every palette mode",
        arguments: TopicID.allCases, PaletteMode.allCases
    )
    func accentResolvesInEveryPalette(_ topic: TopicID, _ mode: PaletteMode) {
        _ = mode.palette[keyPath: topic.accent]
    }
}
