import Testing
@testable import little_Wonder

struct AvatarColorTests {
    @Test("Raw value round-trips for every case", arguments: AvatarColor.allCases)
    func rawValueRoundTrips(_ value: AvatarColor) throws {
        let decoded = try #require(AvatarColor(rawValue: value.rawValue))
        #expect(decoded == value)
    }

    @Test("Identifier equals raw value", arguments: AvatarColor.allCases)
    func idMatchesRawValue(_ value: AvatarColor) {
        #expect(value.id == value.rawValue)
    }

    /// Cartesian product over every avatar colour and every palette mode: confirms
    /// `color(in:)` resolves successfully for every combination the UI can request.
    @Test(
        "Resolves a colour in every palette mode",
        arguments: AvatarColor.allCases, PaletteMode.allCases
    )
    func resolvesColorInEveryPalette(_ avatar: AvatarColor, _ mode: PaletteMode) {
        _ = avatar.color(in: mode.palette)
    }
}
