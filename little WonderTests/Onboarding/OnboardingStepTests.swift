import Testing
@testable import little_Wonder

struct OnboardingStepTests {
    @Test("Exposes all three documented steps")
    func allCasesCount() {
        #expect(OnboardingStep.allCases.count == 3)
    }

    @Test("All cases are unique", arguments: OnboardingStep.allCases)
    func caseIsUnique(_ step: OnboardingStep) {
        let matches = OnboardingStep.allCases.filter { $0 == step }
        #expect(matches.count == 1)
    }

    @Test("Hashing is stable for each case", arguments: OnboardingStep.allCases)
    func hashingIsStable(_ step: OnboardingStep) {
        #expect(step.hashValue == step.hashValue)
        var set = Set<OnboardingStep>()
        set.insert(step)
        set.insert(step)
        #expect(set.count == 1)
    }
}
