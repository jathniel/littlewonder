import Testing
@testable import little_Wonder

@MainActor
struct NumberOrderViewModelTests {
    @Test("Initial state — slots empty, next expected is the first value")
    func initialState() {
        let viewModel = NumberOrderViewModel(sequence: [1, 2, 3], shuffle: false)
        #expect(viewModel.total == 3)
        #expect(viewModel.placedCount == 0)
        #expect(viewModel.slots == [nil, nil, nil])
        #expect(viewModel.tray.map(\.value) == [1, 2, 3])
        #expect(viewModel.nextExpected == 1)
        #expect(!viewModel.celebrate)
    }

    @Test("Placing the expected number fills the next slot")
    func placeExpected() {
        let viewModel = NumberOrderViewModel(sequence: [1, 2, 3], shuffle: false)
        #expect(viewModel.place(1))
        #expect(viewModel.slots[0] == 1)
        #expect(viewModel.placedCount == 1)
        #expect(viewModel.nextExpected == 2)
        #expect(viewModel.tray.count == 2)
    }

    @Test("Placing an out-of-order number is rejected")
    func rejectsWrongOrder() {
        let viewModel = NumberOrderViewModel(sequence: [1, 2, 3], shuffle: false)
        #expect(!viewModel.place(3))
        #expect(viewModel.placedCount == 0)
        #expect(viewModel.nextExpected == 1)
        #expect(viewModel.tray.count == 3)
    }

    @Test("Placing all numbers in order celebrates and fires onComplete")
    func completes() {
        let viewModel = NumberOrderViewModel(sequence: [1, 2, 3], shuffle: false)
        var completions = 0
        viewModel.onComplete = { completions += 1 }
        #expect(viewModel.place(1))
        #expect(viewModel.place(2))
        #expect(viewModel.place(3))
        #expect(viewModel.allPlaced)
        #expect(viewModel.nextExpected == nil)
        #expect(viewModel.celebrate)
        #expect(completions == 1)
    }

    @Test("Reset clears slots and refills the tray")
    func reset() {
        let viewModel = NumberOrderViewModel(sequence: [1, 2, 3], shuffle: false)
        _ = viewModel.place(1)
        viewModel.reset()
        #expect(viewModel.placedCount == 0)
        #expect(viewModel.slots == [nil, nil, nil])
        #expect(viewModel.tray.count == 3)
        #expect(!viewModel.celebrate)
    }
}
