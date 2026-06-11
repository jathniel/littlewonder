import Testing
@testable import little_Wonder

@MainActor
struct AnimalFindViewModelTests {
    /// Two rounds with fixed layouts so counts are deterministic.
    private func makeViewModel() -> AnimalFindViewModel {
        AnimalFindViewModel(
            targets: [.cat, .fish],
            rounds: [
                [.cat, .dog, .cat, .bird],   // 2 cats
                [.fish, .fish, .fish, .ant]  // 3 fish
            ]
        )
    }

    @Test("Initial state — first round target with its matching count")
    func initialState() {
        let viewModel = makeViewModel()
        #expect(viewModel.totalRounds == 2)
        #expect(viewModel.target == .cat)
        #expect(viewModel.matchTotal == 2)
        #expect(viewModel.foundCount == 0)
        #expect(!viewModel.roundComplete)
        #expect(viewModel.completedRounds == 0)
    }

    @Test("Tapping a distractor is ignored; tapping matches completes the round")
    func tapping() {
        let viewModel = makeViewModel()
        // Tap a non-target (dog at index 1) — ignored.
        viewModel.tap(1)
        #expect(viewModel.foundCount == 0)
        // Tap the two cats (indices 0 and 2).
        viewModel.tap(0)
        viewModel.tap(2)
        #expect(viewModel.foundCount == 2)
        #expect(viewModel.roundComplete)
        #expect(viewModel.completedRounds == 1)
        #expect(!viewModel.celebrate) // not the last round
    }

    @Test("Double-tapping the same match counts once")
    func doubleTap() {
        let viewModel = makeViewModel()
        viewModel.tap(0)
        viewModel.tap(0)
        #expect(viewModel.foundCount == 1)
    }

    @Test("Completing the last round celebrates and fires onComplete once")
    func celebrateOnLastRound() {
        let viewModel = makeViewModel()
        var completions = 0
        viewModel.onComplete = { completions += 1 }

        viewModel.tap(0); viewModel.tap(2) // finish round 1 (cats)
        viewModel.advanceRound()
        #expect(viewModel.target == .fish)
        #expect(viewModel.matchTotal == 3)

        viewModel.tap(0); viewModel.tap(1); viewModel.tap(2) // three fish
        #expect(viewModel.roundComplete)
        #expect(viewModel.isLastRound)
        #expect(viewModel.celebrate)
        #expect(completions == 1)
    }

    @Test("advanceRound only advances when the round is complete")
    func guardedAdvance() {
        let viewModel = makeViewModel()
        viewModel.advanceRound()
        #expect(viewModel.roundIndex == 0) // round 1 not complete yet
    }

    @Test("Reset returns to the first round")
    func reset() {
        let viewModel = makeViewModel()
        viewModel.tap(0); viewModel.tap(2)
        viewModel.advanceRound()
        #expect(viewModel.roundIndex == 1)

        viewModel.reset()
        #expect(viewModel.roundIndex == 0)
        #expect(viewModel.target == .cat)
        #expect(viewModel.foundCount == 0)
        #expect(!viewModel.celebrate)
    }
}
