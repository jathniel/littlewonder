import CoreGraphics
import Foundation
import Observation
import SwiftUI

/// Free-play animal scene pad. Mirrors `ColorStampViewModel` with animal glyphs instead
/// of colour blobs. Unscored.
@MainActor
@Observable
final class AnimalStampViewModel {
    struct ToyBoxItem: Identifiable {
        let id: String
        let animal: Animal
    }

    struct PlacedPiece: Identifiable {
        let id: UUID
        let animal: Animal
        var position: CGPoint
    }

    let toyBox: [ToyBoxItem]
    private(set) var pieces: [PlacedPiece]

    var pieceCount: Int { pieces.count }

    init() {
        self.toyBox = Animal.allCases.map { ToyBoxItem(id: "stamp-\($0.rawValue)", animal: $0) }
        self.pieces = []
    }

    func spawn(_ item: ToyBoxItem, at position: CGPoint) {
        pieces.append(PlacedPiece(id: UUID(), animal: item.animal, position: position))
    }

    func move(_ id: UUID, to position: CGPoint) {
        guard let idx = pieces.firstIndex(where: { $0.id == id }) else { return }
        pieces[idx].position = position
    }

    func clear() { pieces = [] }
    func reset() { pieces = [] }
}
