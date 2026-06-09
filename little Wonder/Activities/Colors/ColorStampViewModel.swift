import CoreGraphics
import Foundation
import Observation
import SwiftUI

/// Free-play colour paint pad. Mirrors `NumberStampViewModel` with colour blobs instead
/// of numerals. Unscored.
@MainActor
@Observable
final class ColorStampViewModel {
    struct ToyBoxItem: Identifiable {
        let id: String
        let swatch: ColorSwatch
    }

    struct PlacedPiece: Identifiable {
        let id: UUID
        let swatch: ColorSwatch
        var position: CGPoint
    }

    let toyBox: [ToyBoxItem]
    private(set) var pieces: [PlacedPiece]

    var pieceCount: Int { pieces.count }

    init() {
        self.toyBox = ColorSwatch.allCases.map { ToyBoxItem(id: "stamp-\($0.rawValue)", swatch: $0) }
        self.pieces = []
    }

    func spawn(_ item: ToyBoxItem, at position: CGPoint) {
        pieces.append(PlacedPiece(id: UUID(), swatch: item.swatch, position: position))
    }

    func move(_ id: UUID, to position: CGPoint) {
        guard let idx = pieces.firstIndex(where: { $0.id == id }) else { return }
        pieces[idx].position = position
    }

    func clear() { pieces = [] }
    func reset() { pieces = [] }
}
