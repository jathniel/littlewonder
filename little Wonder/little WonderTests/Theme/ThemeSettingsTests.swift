import Foundation
import Testing
@testable import little_Wonder

@MainActor
struct ThemeSettingsTests {
    /// Each test gets a fresh, isolated suite so parallel execution never bleeds
    /// state across cases.
    private static func makeDefaults() -> UserDefaults {
        let suite = "ThemeSettingsTests-\(UUID().uuidString)"
        return UserDefaults(suiteName: suite)!
    }

    @Test("Empty defaults produce the documented baseline")
    func defaultsWhenEmpty() {
        let settings = ThemeSettings(defaults: Self.makeDefaults())
        #expect(settings.paletteMode == .warm)
        #expect(settings.paceMode == .slow)
    }

    @Test("Palette mode persists across instances", arguments: PaletteMode.allCases)
    func paletteModePersists(_ mode: PaletteMode) {
        let defaults = Self.makeDefaults()
        let writer = ThemeSettings(defaults: defaults)
        writer.paletteMode = mode
        let reader = ThemeSettings(defaults: defaults)
        #expect(reader.paletteMode == mode)
    }

    @Test("Pace mode persists across instances", arguments: PaceMode.allCases)
    func paceModePersists(_ mode: PaceMode) {
        let defaults = Self.makeDefaults()
        let writer = ThemeSettings(defaults: defaults)
        writer.paceMode = mode
        let reader = ThemeSettings(defaults: defaults)
        #expect(reader.paceMode == mode)
    }

    /// Cartesian product: writing both modes in every combination must round-trip
    /// independently — guards against accidental key reuse between the two.
    @Test(
        "Palette and pace round-trip independently",
        arguments: PaletteMode.allCases, PaceMode.allCases
    )
    func bothModesPersistIndependently(_ palette: PaletteMode, _ pace: PaceMode) {
        let defaults = Self.makeDefaults()
        let writer = ThemeSettings(defaults: defaults)
        writer.paletteMode = palette
        writer.paceMode = pace
        let reader = ThemeSettings(defaults: defaults)
        #expect(reader.paletteMode == palette)
        #expect(reader.paceMode == pace)
    }

    @Test("Stored garbage falls back to defaults", arguments: ["", "rainbow", "WARM", "Slow"])
    func garbagePaletteFallsBackToWarm(_ raw: String) {
        let defaults = Self.makeDefaults()
        defaults.set(raw, forKey: "littleWonder.paletteMode")
        let settings = ThemeSettings(defaults: defaults)
        #expect(settings.paletteMode == .warm)
    }

    @Test("Stored garbage in pace key falls back to slow", arguments: ["", "fast", "SLOW", "Playful"])
    func garbagePaceFallsBackToSlow(_ raw: String) {
        let defaults = Self.makeDefaults()
        defaults.set(raw, forKey: "littleWonder.paceMode")
        let settings = ThemeSettings(defaults: defaults)
        #expect(settings.paceMode == .slow)
    }
}
