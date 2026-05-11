import Testing
@testable import little_Wonder

struct PaletteModeTests {
    @Test("Raw value round-trips for every mode", arguments: PaletteMode.allCases)
    func rawValueRoundTrips(_ mode: PaletteMode) throws {
        let decoded = try #require(PaletteMode(rawValue: mode.rawValue))
        #expect(decoded == mode)
    }

    @Test("Identifier equals raw value", arguments: PaletteMode.allCases)
    func idMatchesRawValue(_ mode: PaletteMode) {
        #expect(mode.id == mode.rawValue)
    }

    /// Pairwise zip: each mode resolves to its documented static palette.
    @Test(
        "palette resolves to the matching static palette",
        arguments: zip(
            [PaletteMode.warm, .cool, .neutral] as [PaletteMode],
            [Palette.warm, .cool, .neutral] as [Palette]
        )
    )
    func paletteMatches(_ mode: PaletteMode, _ expected: Palette) {
        #expect(mode.palette == expected)
    }

    @Test("Modes produce three distinct palettes")
    func palettesAreDistinct() {
        let palettes = PaletteMode.allCases.map(\.palette)
        #expect(Set(palettes.map(\.paper)).count == palettes.count)
    }
}
