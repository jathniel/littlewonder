import Testing
@testable import little_Wonder

@MainActor
struct NumberCountViewModelTests {
    @Test("Initial state — first round populated, nothing counted")
    func initialState() {
        let viewModel = NumberCountViewModel(roundCounts: [2, 3, 4])
        #expect(viewModel.totalRounds == 3)
        #expect(viewModel.roundIndex == 0)
        #expect(viewModel.currentCount == 2)
        #expect(viewModel.items.count == 2)
        #expect(viewModel.countedCount == 0)
        #expect(!viewModel.roundComplete)
        #expect(!viewModel.celebrate)
    }

    @Test("Tapping every item completes the round")
    func tappingCompletesRound() {
        let viewModel = NumberCountViewModel(roundCounts: [2, 3])
        for item in viewModel.items { viewModel.tap(item.id) }
        #expect(viewModel.countedCount == 2)
        #expect(viewModel.roundComplete)
        #expect(!viewModel.isLastRound)
        #expect(!viewModel.celebrate)
    }

    @Test("Tapping the same item twice does not double-count")
    func noDoubleCount() {
        let viewModel = NumberCountViewModel(roundCounts: [3])
        let first = viewModel.items[0].id
        viewModel.tap(first)
        viewModel.tap(first)
        #expect(viewModel.countedCount == 1)
    }

    @Test("Advancing moves to the next round with a fresh item set")
    func advanceRound() {
        let viewModel = NumberCountViewModel(roundCounts: [2, 4])
        for item in viewModel.items { viewModel.tap(item.id) }
        viewModel.advanceRound()
        #expect(viewModel.roundIndex == 1)
        #expect(viewModel.currentCount == 4)
        #expect(viewModel.items.count == 4)
        #expect(viewModel.countedCount == 0)
    }

    @Test("Advancing before the round is complete is a no-op")
    func advanceGuarded() {
        let viewModel = NumberCountViewModel(roundCounts: [3, 2])
        viewModel.tap(viewModel.items[0].id)
        viewModel.advanceRound()
        #expect(viewModel.roundIndex == 0)
    }

    @Test("Finishing the last round celebrates and fires onComplete")
    func finishCelebrates() {
        let viewModel = NumberCountViewModel(roundCounts: [2])
        var completions = 0
        viewModel.onComplete = { completions += 1 }
        for item in viewModel.items { viewModel.tap(item.id) }
        #expect(viewModel.celebrate)
        #expect(completions == 1)
    }

    @Test("Reset returns to the first round")
    func reset() {
        let viewModel = NumberCountViewModel(roundCounts: [2, 3])
        for item in viewModel.items { viewModel.tap(item.id) }
        viewModel.advanceRound()
        viewModel.reset()
        #expect(viewModel.roundIndex == 0)
        #expect(viewModel.items.count == 2)
        #expect(viewModel.countedCount == 0)
        #expect(!viewModel.celebrate)
    }
}
