import Testing
@testable import little_Wonder

@MainActor
struct ColorMixViewModelTests {
    @Test("Initial state — first target, empty selection, three primary pots")
    func initialState() {
        let viewModel = ColorMixViewModel(targets: [.orange, .green])
        #expect(viewModel.pots == ColorSwatch.primaries)
        #expect(viewModel.totalRounds == 2)
        #expect(viewModel.target == .orange)
        #expect(viewModel.selection.isEmpty)
        #expect(viewModel.result == nil)
        #expect(!viewModel.solvedRound)
        #expect(viewModel.completedRounds == 0)
    }

    @Test("Correct mix solves the round and shows the result")
    func correctMix() {
        let viewModel = ColorMixViewModel(targets: [.orange, .green])
        viewModel.tap(.red)
        viewModel.tap(.yellow)
        #expect(viewModel.result == .orange)
        #expect(viewModel.solvedRound)
        #expect(viewModel.completedRounds == 1)
        #expect(!viewModel.celebrate) // not last round
    }

    @Test("Wrong mix shows a (different) result but does not solve")
    func wrongMix() {
        let viewModel = ColorMixViewModel(targets: [.orange, .green])
        viewModel.tap(.red)
        viewModel.tap(.blue) // makes purple, not orange
        #expect(viewModel.result == .purple)
        #expect(!viewModel.solvedRound)
    }

    @Test("Tapping a selected pot again deselects it")
    func toggleDeselect() {
        let viewModel = ColorMixViewModel(targets: [.orange])
        viewModel.tap(.red)
        #expect(viewModel.selection == [.red])
        viewModel.tap(.red)
        #expect(viewModel.selection.isEmpty)
    }

    @Test("A tap after two are chosen restarts the mix with the new colour")
    func restartAfterTwo() {
        let viewModel = ColorMixViewModel(targets: [.green])
        viewModel.tap(.red)
        viewModel.tap(.blue) // purple result, not solved
        #expect(viewModel.result == .purple)
        viewModel.tap(.yellow) // restart
        #expect(viewModel.selection == [.yellow])
        #expect(viewModel.result == nil)
        viewModel.tap(.blue)
        #expect(viewModel.result == .green)
        #expect(viewModel.solvedRound)
    }

    @Test("Solving the last round celebrates and fires onComplete once")
    func celebrateOnLastRound() {
        let viewModel = ColorMixViewModel(targets: [.orange, .purple])
        var completions = 0
        viewModel.onComplete = { completions += 1 }

        viewModel.tap(.red); viewModel.tap(.yellow) // orange
        viewModel.advanceRound()
        #expect(viewModel.target == .purple)

        viewModel.tap(.red); viewModel.tap(.blue) // purple
        #expect(viewModel.solvedRound)
        #expect(viewModel.isLastRound)
        #expect(viewModel.celebrate)
        #expect(completions == 1)
    }

    @Test("No further taps register once a round is solved")
    func lockedAfterSolve() {
        let viewModel = ColorMixViewModel(targets: [.orange, .green])
        viewModel.tap(.red); viewModel.tap(.yellow)
        #expect(viewModel.solvedRound)
        viewModel.tap(.blue) // ignored while solved
        #expect(viewModel.selection == [.red, .yellow])
    }

    @Test("Reset returns to the first round with no selection")
    func reset() {
        let viewModel = ColorMixViewModel(targets: [.orange, .green])
        viewModel.tap(.red); viewModel.tap(.yellow)
        viewModel.advanceRound()
        #expect(viewModel.roundIndex == 1)

        viewModel.reset()
        #expect(viewModel.roundIndex == 0)
        #expect(viewModel.selection.isEmpty)
        #expect(!viewModel.solvedRound)
        #expect(!viewModel.celebrate)
    }
}
