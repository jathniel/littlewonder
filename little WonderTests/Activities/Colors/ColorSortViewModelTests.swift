import Foundation
import Testing
@testable import little_Wonder

@MainActor
struct ColorSortViewModelTests {
    @Test("Initial state — empty bins, full tray, every tray colour has a bin")
    func initialState() {
        let viewModel = ColorSortViewModel(colors: [.red, .blue, .yellow], perColor: 2, shuffle: false)
        #expect(viewModel.bins.count == 3)
        #expect(viewModel.tray.count == 6)
        #expect(viewModel.remaining == 6)
        #expect(viewModel.total == 6)
        #expect(!viewModel.allSorted)
        for piece in viewModel.tray {
            #expect(viewModel.bins.contains { $0.swatch == piece.swatch })
        }
        for bin in viewModel.bins { #expect(bin.placed.isEmpty) }
    }

    @Test("Placing a piece moves it into the matching colour bin")
    func placeMatchingBin() {
        let viewModel = ColorSortViewModel(colors: [.red, .blue, .yellow], perColor: 1, shuffle: false)
        let piece = viewModel.tray[0]
        let didPlace = viewModel.place(pieceID: piece.id)
        #expect(didPlace)
        #expect(viewModel.remaining == 2)
        let bin = viewModel.bins.first { $0.swatch == piece.swatch }
        #expect(bin?.placed.contains { $0.id == piece.id } == true)
    }

    @Test("Unknown piece id is a no-op")
    func placeUnknown() {
        let viewModel = ColorSortViewModel(colors: [.red, .blue], perColor: 1, shuffle: false)
        #expect(!viewModel.place(pieceID: UUID()))
        #expect(viewModel.remaining == 2)
    }

    @Test("Emptying the tray celebrates and fires onComplete once")
    func celebrateWhenSorted() {
        let viewModel = ColorSortViewModel(colors: [.red, .blue, .yellow], perColor: 1, shuffle: false)
        var completions = 0
        viewModel.onComplete = { completions += 1 }
        while let piece = viewModel.tray.first {
            viewModel.place(pieceID: piece.id)
        }
        #expect(viewModel.allSorted)
        #expect(viewModel.celebrate)
        #expect(completions == 1)
        #expect(viewModel.total == 3)
    }

    @Test("Reset empties bins and refills the tray")
    func reset() {
        let viewModel = ColorSortViewModel(colors: [.red, .blue], perColor: 2, shuffle: false)
        while let piece = viewModel.tray.first { viewModel.place(pieceID: piece.id) }
        #expect(viewModel.remaining == 0)

        viewModel.reset()
        #expect(viewModel.remaining == 4)
        #expect(!viewModel.celebrate)
        for bin in viewModel.bins { #expect(bin.placed.isEmpty) }
    }
}
