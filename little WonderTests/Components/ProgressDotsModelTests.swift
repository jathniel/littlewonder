import Testing
@testable import little_Wonder

struct ProgressDotsModelTests {
    @Test("Mid-progress highlights the active index and reports the matching step")
    func midProgress() {
        let model = ProgressDotsModel(count: 4, active: 1)
        #expect(model.highlightedIndex == 1)
        #expect(model.stepNumber == 2)
    }

    @Test("Start of an activity highlights the first dot")
    func startOfActivity() {
        let model = ProgressDotsModel(count: 4, active: 0)
        #expect(model.highlightedIndex == 0)
        #expect(model.stepNumber == 1)
    }

    @Test("Completion clamps to the last dot instead of overflowing")
    func completionClamps() {
        let model = ProgressDotsModel(count: 4, active: 4)
        #expect(model.highlightedIndex == 3)
        #expect(model.stepNumber == 4)
    }

    @Test("Over-completion never announces a step beyond the total")
    func overCompletionClamps() {
        let model = ProgressDotsModel(count: 3, active: 5)
        #expect(model.highlightedIndex == 2)
        #expect(model.stepNumber == 3)
    }
}
