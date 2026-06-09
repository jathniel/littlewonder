import Testing
@testable import little_Wonder

struct ColorSwatchTests {
    @Test("Primaries and secondaries are partitioned correctly")
    func primaryPartition() {
        #expect(ColorSwatch.primaries == [.red, .yellow, .blue])
        #expect(ColorSwatch.secondaries == [.orange, .green, .purple])
        for swatch in ColorSwatch.primaries { #expect(swatch.isPrimary && !swatch.isSecondary) }
        for swatch in ColorSwatch.secondaries { #expect(swatch.isSecondary && !swatch.isPrimary) }
    }

    @Test("Mixing two distinct primaries yields the expected secondary, order-independent", arguments: [
        (ColorSwatch.red, ColorSwatch.yellow, ColorSwatch.orange),
        (.blue, .yellow, .green),
        (.red, .blue, .purple)
    ])
    func mixingPrimaries(a: ColorSwatch, b: ColorSwatch, expected: ColorSwatch) {
        #expect(ColorSwatch.mix(a, b) == expected)
        #expect(ColorSwatch.mix(b, a) == expected)
    }

    @Test("Mixing a colour with itself is invalid")
    func mixingSameColour() {
        for swatch in ColorSwatch.allCases {
            #expect(ColorSwatch.mix(swatch, swatch) == nil)
        }
    }

    @Test("Mixing anything involving a secondary is invalid")
    func mixingWithSecondary() {
        #expect(ColorSwatch.mix(.orange, .blue) == nil)
        #expect(ColorSwatch.mix(.green, .red) == nil)
        #expect(ColorSwatch.mix(.orange, .purple) == nil)
    }

    @Test("Each secondary reports the primaries that make it")
    func mixIngredients() {
        for secondary in ColorSwatch.secondaries {
            let ingredients = secondary.mixIngredients
            #expect(ingredients != nil)
            if let (a, b) = ingredients {
                #expect(ColorSwatch.mix(a, b) == secondary)
            }
        }
        for primary in ColorSwatch.primaries {
            #expect(primary.mixIngredients == nil)
        }
    }
}
