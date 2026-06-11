import Testing
@testable import little_Wonder

struct NarrationPlanTests {
    @Test("Narration off produces no plan", arguments: NarrationLanguage.allCases)
    func narrationOffProducesNoPlan(_ language: NarrationLanguage) {
        #expect(NarrationPlan.make(saying: "Hello", isNarrationOn: false, language: language) == nil)
    }

    @Test("Blank text produces no plan", arguments: ["", "   ", " \n\t "])
    func blankTextProducesNoPlan(_ text: String) {
        #expect(NarrationPlan.make(saying: text, isNarrationOn: true, language: .en) == nil)
    }

    @Test("Plan keeps the text, trimmed of surrounding whitespace")
    func planTrimsWhitespace() throws {
        let plan = try #require(NarrationPlan.make(saying: "  Find the circle \n", isNarrationOn: true, language: .en))
        #expect(plan.text == "Find the circle")
    }

    @Test(
        "Each language maps to its synthesis voice",
        arguments: zip(NarrationLanguage.allCases, ["en-US", "es-ES", "fr-FR"])
    )
    func languageMapsToVoice(_ language: NarrationLanguage, _ expected: String) throws {
        let plan = try #require(NarrationPlan.make(saying: "Hello", isNarrationOn: true, language: language))
        #expect(plan.voiceLanguage == expected)
    }

    @Test("Speaking rate is slower than the synthesizer default but audible")
    func rateIsSlowerThanDefault() {
        #expect(NarrationPlan.rate > 0.2)
        #expect(NarrationPlan.rate < 0.5)
    }
}
