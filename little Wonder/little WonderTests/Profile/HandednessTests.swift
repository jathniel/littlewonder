import Testing
@testable import little_Wonder

struct HandednessTests {
    @Test("Raw value round-trips for every case", arguments: Handedness.allCases)
    func rawValueRoundTrips(_ value: Handedness) throws {
        let decoded = try #require(Handedness(rawValue: value.rawValue))
        #expect(decoded == value)
    }

    @Test("Identifier equals raw value", arguments: Handedness.allCases)
    func idMatchesRawValue(_ value: Handedness) {
        #expect(value.id == value.rawValue)
    }

    @Test("Localized string is non-empty", arguments: Handedness.allCases)
    func localizedIsNonEmpty(_ value: Handedness) {
        #expect(value.localized.isEmpty == false)
    }

    @Test(
        "Unknown raw values fail to decode",
        arguments: ["", " ", "ambidextrous", "LEFT", "Right"]
    )
    func unknownRawValuesReturnNil(_ raw: String) {
        #expect(Handedness(rawValue: raw) == nil)
    }
}
