import CoreGraphics
import Testing
@testable import little_Wonder

@MainActor
struct NumberMatchViewModelTests {
    @Test("Initial state — 3 or 4 pieces in tray, none placed")
    func initialState() {
        let viewModel = NumberMatchViewModel()
        #expect((3...4).contains(viewModel.pieces.count))
        #expect(viewModel.placedCount == 0)
        #expect(!viewModel.celebrate)
        for piece in viewModel.pieces {
            #expect(!piece.placed)
            #expect(piece.position == piece.traySlot)
            #expect(NumberMatchViewModel.eligibleValues.contains(piece.value))
        }
    }

    @Test("Drop within snap radius marks placed and snaps to target")
    func dropOnTarget() {
        let viewModel = NumberMatchViewModel()
        let piece = viewModel.pieces[0]
        viewModel.updateDrag(piece.id, to: piece.target)
        let didPlace = viewModel.endDrag(piece.id)
        #expect(didPlace)
        let updated = viewModel.pieces[0]
        #expect(updated.placed)
        #expect(updated.position == piece.target)
    }

    @Test("Drop outside snap radius returns piece to its tray slot")
    func dropOffTarget() {
        let viewModel = NumberMatchViewModel()
        let piece = viewModel.pieces[0]
        let far = CGPoint(x: piece.target.x + 400, y: piece.target.y + 400)
        viewModel.updateDrag(piece.id, to: far)
        let didPlace = viewModel.endDrag(piece.id)
        #expect(!didPlace)
        let updated = viewModel.pieces[0]
        #expect(!updated.placed)
        #expect(updated.position == piece.traySlot)
    }

    @Test("All-placed flips celebrate and fires onComplete once")
    func celebrate() {
        let viewModel = NumberMatchViewModel()
        var completions = 0
        viewModel.onComplete = { completions += 1 }
        for piece in viewModel.pieces {
            viewModel.updateDrag(piece.id, to: piece.target)
            _ = viewModel.endDrag(piece.id)
        }
        #expect(viewModel.allPlaced)
        #expect(viewModel.celebrate)
        #expect(completions == 1)
    }

    @Test("Reset clears placements")
    func reset() {
        let viewModel = NumberMatchViewModel()
        let piece = viewModel.pieces[0]
        viewModel.updateDrag(piece.id, to: piece.target)
        _ = viewModel.endDrag(piece.id)
        #expect(viewModel.placedCount == 1)

        viewModel.reset()
        #expect(viewModel.placedCount == 0)
        #expect(!viewModel.celebrate)
        for piece in viewModel.pieces {
            #expect(!piece.placed)
            #expect(piece.position == piece.traySlot)
        }
    }
}
