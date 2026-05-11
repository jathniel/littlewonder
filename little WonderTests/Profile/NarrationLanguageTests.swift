import Testing
@testable import little_Wonder

struct NarrationLanguageTests {
    @Test("Raw value round-trips for every case", arguments: NarrationLanguage.allCases)
    func rawValueRoundTrips(_ value: NarrationLanguage) throws {
        let decoded = try #require(NarrationLanguage(rawValue: value.rawValue))
        #expect(decoded == value)
    }

    @Test("Identifier equals raw value", arguments: NarrationLanguage.allCases)
    func idMatchesRawValue(_ value: NarrationLanguage) {
        #expect(value.id == value.rawValue)
    }

    @Test("Localized string is non-empty", arguments: NarrationLanguage.allCases)
    func localizedIsNonEmpty(_ value: NarrationLanguage) {
        #expect(value.localized.isEmpty == false)
    }

    @Test(
        "Unknown raw values fail to decode",
        arguments: ["", "EN", "english", "de", "zh"]
    )
    func unknownRawValuesReturnNil(_ raw: String) {
        #expect(NarrationLanguage(rawValue: raw) == nil)
    }
}
