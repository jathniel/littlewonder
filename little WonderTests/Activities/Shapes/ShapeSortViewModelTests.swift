import Foundation
import Testing
@testable import little_Wonder

@MainActor
struct ShapeSortViewModelTests {
    @Test("Initial tray has six pieces and three bins")
    func initialState() {
        let viewModel = ShapeSortViewModel()
        #expect(viewModel.tray.count == 6)
        #expect(viewModel.bins.count == 3)
    }

    @Test("Placing a piece moves it into the matching bin and decrements tray count")
    func placePiece() {
        let viewModel = ShapeSortViewModel()
        let circlePiece = viewModel.tray.first { $0.kind == .circle }!
        let circleBinCountBefore = viewModel.bins.first { $0.kind == .circle }!.placed.count
        let placed = viewModel.place(pieceID: circlePiece.id)
        #expect(placed)
        #expect(viewModel.remaining == 5)
        #expect(viewModel.bins.first { $0.kind == .circle }!.placed.count == circleBinCountBefore + 1)
    }

    @Test("Placing an unknown piece id is a no-op")
    func placeUnknown() {
        let viewModel = ShapeSortViewModel()
        let before = viewModel.remaining
        let placed = viewModel.place(pieceID: UUID())
        #expect(!placed)
        #expect(viewModel.remaining == before)
    }

    @Test("Reset restores tray and bins to their initial state")
    func reset() {
        let viewModel = ShapeSortViewModel()
        let piece = viewModel.tray[0]
        _ = viewModel.place(pieceID: piece.id)
        viewModel.reset()
        #expect(viewModel.tray.count == 6)
    }
}
