import CoreGraphics
import Foundation
import Observation
import SwiftUI

/// Free-play numeral stamp pad. Mirrors `ShapeBuildViewModel`'s free-play mode with
/// numerals instead of shapes. Unscored.
@MainActor
@Observable
final class NumberStampViewModel {
    struct ToyBoxItem: Identifiable {
        let id: String
        let value: Int
        let color: KeyPath<Palette, Color>
    }

    struct PlacedPiece: Identifiable {
        let id: UUID
        let value: Int
        let color: KeyPath<Palette, Color>
        var position: CGPoint
    }

    let toyBox: [ToyBoxItem]
    private(set) var pieces: [PlacedPiece]

    var pieceCount: Int { pieces.count }

    init() {
        self.toyBox = Self.defaultToyBox
        self.pieces = []
    }

    func spawn(_ item: ToyBoxItem, at position: CGPoint) {
        pieces.append(PlacedPiece(id: UUID(), value: item.value, color: item.color, position: position))
    }

    func move(_ id: UUID, to position: CGPoint) {
        guard let idx = pieces.firstIndex(where: { $0.id == id }) else { return }
        pieces[idx].position = position
    }

    func clear() { pieces = [] }
    func reset() { pieces = [] }

    private static let palette: [KeyPath<Palette, Color>] = [
        \Palette.berry, \Palette.mustard, \Palette.oak, \Palette.terracotta,
        \Palette.sky, \Palette.sage, \Palette.plum
    ]

    private static let defaultToyBox: [ToyBoxItem] = (1...9).map { value in
        ToyBoxItem(id: "stamp-\(value)", value: value, color: palette[(value - 1) % palette.count])
    }
}
