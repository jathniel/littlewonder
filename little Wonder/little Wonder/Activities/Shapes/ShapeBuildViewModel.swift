import CoreGraphics
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ShapeBuildViewModel {
    enum Mode { case build, freePlay }

    struct ToyBoxItem: Identifiable {
        let id: String
        let kind: ShapeKind
        let color: KeyPath<Palette, Color>
    }

    struct PlacedPiece: Identifiable {
        let id: UUID
        let kind: ShapeKind
        let color: KeyPath<Palette, Color>
        var position: CGPoint
        var scale: CGSize
        var rotation: Angle
    }

    let mode: Mode
    let toyBox: [ToyBoxItem]
    private(set) var pieces: [PlacedPiece]

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .build:
            self.toyBox = Self.buildToyBox
            self.pieces = Self.defaultHouse
        case .freePlay:
            self.toyBox = Self.freePlayToyBox
            self.pieces = []
        }
    }

    var pieceCount: Int { pieces.count }

    func spawn(_ item: ToyBoxItem, at position: CGPoint) {
        let placed = PlacedPiece(
            id: UUID(),
            kind: item.kind,
            color: item.color,
            position: position,
            scale: CGSize(width: 1, height: 1),
            rotation: .zero
        )
        pieces.append(placed)
    }

    func move(_ id: UUID, to position: CGPoint) {
        guard let idx = pieces.firstIndex(where: { $0.id == id }) else { return }
        pieces[idx].position = position
    }

    func reset() {
        pieces = (mode == .build) ? Self.defaultHouse : []
    }

    func clear() {
        pieces = []
    }

    private static let buildToyBox: [ToyBoxItem] = [
        ToyBoxItem(id: "square",    kind: .square,    color: \Palette.oak),
        ToyBoxItem(id: "triangle",  kind: .triangle,  color: \Palette.terracotta),
        ToyBoxItem(id: "rectangle", kind: .rectangle, color: \Palette.ink),
        ToyBoxItem(id: "circle",    kind: .circle,    color: \Palette.mustard),
        ToyBoxItem(id: "hexagon",   kind: .hexagon,   color: \Palette.sage),
        ToyBoxItem(id: "star",      kind: .star,      color: \Palette.berry)
    ]

    private static let freePlayToyBox: [ToyBoxItem] = [
        ToyBoxItem(id: "circle",     kind: .circle,     color: \Palette.berry),
        ToyBoxItem(id: "square",     kind: .square,     color: \Palette.mustard),
        ToyBoxItem(id: "rectangle",  kind: .rectangle,  color: \Palette.oak),
        ToyBoxItem(id: "triangle",   kind: .triangle,   color: \Palette.terracotta),
        ToyBoxItem(id: "oval",       kind: .oval,       color: \Palette.sky),
        ToyBoxItem(id: "hexagon",    kind: .hexagon,    color: \Palette.sage),
        ToyBoxItem(id: "star",       kind: .star,       color: \Palette.mustard),
        ToyBoxItem(id: "heart",      kind: .heart,      color: \Palette.berry),
        ToyBoxItem(id: "diamond",    kind: .diamond,    color: \Palette.plum),
        ToyBoxItem(id: "semicircle", kind: .semicircle, color: \Palette.sky)
    ]

    private static let defaultHouse: [PlacedPiece] = [
        // Ground
        PlacedPiece(id: UUID(), kind: .rectangle, color: \Palette.sage,
                    position: CGPoint(x: 400, y: 460),
                    scale: CGSize(width: 1.6, height: 0.32),
                    rotation: .zero),
        // House body
        PlacedPiece(id: UUID(), kind: .square, color: \Palette.oak,
                    position: CGPoint(x: 380, y: 320),
                    scale: CGSize(width: 1, height: 1), rotation: .zero),
        // Roof
        PlacedPiece(id: UUID(), kind: .triangle, color: \Palette.terracotta,
                    position: CGPoint(x: 380, y: 220),
                    scale: CGSize(width: 1.1, height: 0.9), rotation: .zero),
        // Door
        PlacedPiece(id: UUID(), kind: .rectangle, color: \Palette.ink,
                    position: CGPoint(x: 380, y: 360),
                    scale: CGSize(width: 0.25, height: 0.6), rotation: .zero),
        // Sun
        PlacedPiece(id: UUID(), kind: .circle, color: \Palette.mustard,
                    position: CGPoint(x: 620, y: 140),
                    scale: CGSize(width: 0.8, height: 0.8), rotation: .zero),
        // Tree top
        PlacedPiece(id: UUID(), kind: .circle, color: \Palette.sage,
                    position: CGPoint(x: 590, y: 320),
                    scale: CGSize(width: 0.9, height: 0.9), rotation: .zero),
        // Trunk
        PlacedPiece(id: UUID(), kind: .rectangle, color: \Palette.oak,
                    position: CGPoint(x: 590, y: 400),
                    scale: CGSize(width: 0.25, height: 0.7), rotation: .zero)
    ]
}
