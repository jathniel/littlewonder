import Testing
@testable import little_Wonder

struct ShapeKindTests {
    @Test("Raw value round-trips for every shape", arguments: ShapeKind.allCases)
    func rawValueRoundTrips(_ shape: ShapeKind) throws {
        let decoded = try #require(ShapeKind(rawValue: shape.rawValue))
        #expect(decoded == shape)
    }

    @Test("Every case has a unique raw value")
    func rawValuesAreUnique() {
        let raws = ShapeKind.allCases.map(\.rawValue)
        #expect(Set(raws).count == raws.count)
    }

    @Test(
        "Unknown raw values fail to decode",
        arguments: ["", "CIRCLE", "Circle", "round", "blob"]
    )
    func unknownRawValuesReturnNil(_ raw: String) {
        #expect(ShapeKind(rawValue: raw) == nil)
    }
}
