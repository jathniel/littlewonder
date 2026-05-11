import Foundation
import Testing
@testable import little_Wonder

@MainActor
struct ProfileStoreTests {
    /// Returns a freshly-scoped `UserDefaults` so each test runs against an isolated
    /// suite. Without isolation, ProfileStore would observe state from `.standard`
    /// and tests would race against each other under parallel execution.
    private static func makeDefaults() -> UserDefaults {
        let suite = "ProfileStoreTests-\(UUID().uuidString)"
        return UserDefaults(suiteName: suite)!
    }

    // MARK: - Defaults

    @Test("Empty defaults produce documented baseline values")
    func defaultsWhenEmpty() {
        let store = ProfileStore(defaults: Self.makeDefaults())
        #expect(store.name == "")
        #expect(store.age == 3)
        #expect(store.avatarShape == .circle)
        #expect(store.avatarColor == .terracotta)
        #expect(store.narrationLanguage == .en)
        #expect(store.handedness == .right)
        #expect(store.isNarrationOn == true)
    }

    // MARK: - displayName

    /// Each row pairs an input name with whether `displayName` should fall back to
    /// the localized placeholder. Pure-whitespace strings collapse to empty after
    /// trimming, so they should also fall back.
    struct DisplayNameCase: Sendable, CustomTestStringConvertible {
        let input: String
        let shouldFallBack: Bool
        var testDescription: String {
            "input=\(input.debugDescription) fallback=\(shouldFallBack)"
        }
    }

    @Test(
        "displayName falls back only for empty or whitespace-only names",
        arguments: [
            DisplayNameCase(input: "", shouldFallBack: true),
            DisplayNameCase(input: " ", shouldFallBack: true),
            DisplayNameCase(input: "\n\t ", shouldFallBack: true),
            DisplayNameCase(input: "Alice", shouldFallBack: false),
            DisplayNameCase(input: "  Alice  ", shouldFallBack: false),
            DisplayNameCase(input: "李雷", shouldFallBack: false),
            DisplayNameCase(input: "🐻", shouldFallBack: false)
        ]
    )
    func displayName(_ scenario: DisplayNameCase) {
        let store = ProfileStore(defaults: Self.makeDefaults())
        store.name = scenario.input
        if scenario.shouldFallBack {
            #expect(store.displayName != scenario.input)
            #expect(store.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        } else {
            #expect(store.displayName == scenario.input)
        }
    }

    // MARK: - Persistence round-trips

    @Test("Avatar shape persists for every shape", arguments: ShapeKind.allCases)
    func avatarShapePersists(_ shape: ShapeKind) {
        let defaults = Self.makeDefaults()
        let writer = ProfileStore(defaults: defaults)
        writer.avatarShape = shape
        let reader = ProfileStore(defaults: defaults)
        #expect(reader.avatarShape == shape)
    }

    @Test("Avatar colour persists for every colour", arguments: AvatarColor.allCases)
    func avatarColorPersists(_ color: AvatarColor) {
        let defaults = Self.makeDefaults()
        let writer = ProfileStore(defaults: defaults)
        writer.avatarColor = color
        let reader = ProfileStore(defaults: defaults)
        #expect(reader.avatarColor == color)
    }

    @Test("Narration language persists for every language", arguments: NarrationLanguage.allCases)
    func narrationLanguagePersists(_ language: NarrationLanguage) {
        let defaults = Self.makeDefaults()
        let writer = ProfileStore(defaults: defaults)
        writer.narrationLanguage = language
        let reader = ProfileStore(defaults: defaults)
        #expect(reader.narrationLanguage == language)
    }

    @Test("Handedness persists for every option", arguments: Handedness.allCases)
    func handednessPersists(_ handedness: Handedness) {
        let defaults = Self.makeDefaults()
        let writer = ProfileStore(defaults: defaults)
        writer.handedness = handedness
        let reader = ProfileStore(defaults: defaults)
        #expect(reader.handedness == handedness)
    }

    @Test("Age persists across a representative range", arguments: [0, 1, 3, 5, 8, 12, 99])
    func agePersists(_ age: Int) {
        let defaults = Self.makeDefaults()
        let writer = ProfileStore(defaults: defaults)
        writer.age = age
        let reader = ProfileStore(defaults: defaults)
        #expect(reader.age == age)
    }

    @Test("Narration toggle persists in both states", arguments: [true, false])
    func narrationTogglePersists(_ isOn: Bool) {
        let defaults = Self.makeDefaults()
        let writer = ProfileStore(defaults: defaults)
        writer.isNarrationOn = isOn
        let reader = ProfileStore(defaults: defaults)
        #expect(reader.isNarrationOn == isOn)
    }

    @Test("Name persists across UTF-8 inputs", arguments: ["", "Alice", "  spaced  ", "李雷", "🐻"])
    func namePersists(_ name: String) {
        let defaults = Self.makeDefaults()
        let writer = ProfileStore(defaults: defaults)
        writer.name = name
        let reader = ProfileStore(defaults: defaults)
        #expect(reader.name == name)
    }
}
