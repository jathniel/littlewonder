import Foundation
import Testing
@testable import little_Wonder

@MainActor
struct AnimalSortViewModelTests {
    @Test("Initial state — empty bins, full tray, every tray animal has a matching habitat bin")
    func initialState() {
        let viewModel = AnimalSortViewModel(habitats: [.pets, .bugs, .water], perHabitat: 2, shuffle: false)
        #expect(viewModel.bins.count == 3)
        #expect(viewModel.tray.count == 6)
        #expect(viewModel.remaining == 6)
        #expect(viewModel.total == 6)
        #expect(!viewModel.allSorted)
        for piece in viewModel.tray {
            #expect(viewModel.bins.contains { $0.habitat == piece.animal.habitat })
        }
        for bin in viewModel.bins { #expect(bin.placed.isEmpty) }
    }

    @Test("Placing a piece moves it into the bin of the animal's habitat")
    func placeMatchingBin() {
        let viewModel = AnimalSortViewModel(habitats: [.pets, .bugs, .water], perHabitat: 1, shuffle: false)
        let piece = viewModel.tray[0]
        let didPlace = viewModel.place(pieceID: piece.id)
        #expect(didPlace)
        #expect(viewModel.remaining == 2)
        let bin = viewModel.bins.first { $0.habitat == piece.animal.habitat }
        #expect(bin?.placed.contains { $0.id == piece.id } == true)
    }

    @Test("Unknown piece id is a no-op")
    func placeUnknown() {
        let viewModel = AnimalSortViewModel(habitats: [.pets, .bugs], perHabitat: 1, shuffle: false)
        #expect(!viewModel.place(pieceID: UUID()))
        #expect(viewModel.remaining == 2)
    }

    @Test("Emptying the tray celebrates and fires onComplete once")
    func celebrateWhenSorted() {
        let viewModel = AnimalSortViewModel(habitats: [.pets, .bugs, .water], perHabitat: 1, shuffle: false)
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
        let viewModel = AnimalSortViewModel(habitats: [.pets, .bugs], perHabitat: 2, shuffle: false)
        while let piece = viewModel.tray.first { viewModel.place(pieceID: piece.id) }
        #expect(viewModel.remaining == 0)

        viewModel.reset()
        #expect(viewModel.remaining == 4)
        #expect(!viewModel.celebrate)
        for bin in viewModel.bins { #expect(bin.placed.isEmpty) }
    }

    @Test("Default init picks three habitats that each have enough animals to fill the tray")
    func defaultHabitatsAreFillable() {
        let viewModel = AnimalSortViewModel()
        #expect(viewModel.bins.count == 3)
        // Two distinct animals per habitat by default.
        #expect(viewModel.tray.count == 6)
        let trayAnimals = viewModel.tray.map(\.animal)
        #expect(Set(trayAnimals).count == trayAnimals.count) // distinct animals
    }
}
