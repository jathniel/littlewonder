import CoreGraphics
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ShapeSortViewModel {
    struct Bin: Identifiable {
        let id: ShapeKind
        let accent: KeyPath<Palette, Color>
        let labelKey: LocalizedStringKey
        var placed: [PlacedPiece]

        var kind: ShapeKind { id }
    }

    struct PlacedPiece: Identifiable {
        let id: UUID
        let kind: ShapeKind
        let color: KeyPath<Palette, Color>
        /// Position inside the bin, in the bin's local coordinate space.
        let offset: CGSize
    }

    struct TrayPiece: Identifiable {
        let id: UUID
        let kind: ShapeKind
        let color: KeyPath<Palette, Color>
    }

    private(set) var bins: [Bin]
    private(set) var tray: [TrayPiece]

    var remaining: Int { tray.count }
    var total: Int { tray.count + bins.reduce(0) { $0 + $1.placed.count } }

    init() {
        self.bins = [
            Bin(id: .circle,   accent: \Palette.terracotta, labelKey: "shapeSortBinCircles",   placed: Self.initialCircles()),
            Bin(id: .square,   accent: \Palette.sage,       labelKey: "shapeSortBinSquares",   placed: Self.initialSquares()),
            Bin(id: .triangle, accent: \Palette.mustard,    labelKey: "shapeSortBinTriangles", placed: Self.initialTriangles())
        ]
        self.tray = [
            TrayPiece(id: UUID(), kind: .circle,   color: \Palette.terracotta),
            TrayPiece(id: UUID(), kind: .square,   color: \Palette.sage),
            TrayPiece(id: UUID(), kind: .triangle, color: \Palette.mustard),
            TrayPiece(id: UUID(), kind: .circle,   color: \Palette.terracotta),
            TrayPiece(id: UUID(), kind: .square,   color: \Palette.sage),
            TrayPiece(id: UUID(), kind: .triangle, color: \Palette.mustard)
        ]
    }

    /// Snap any tray piece into the matching bin — design has no fail state, so
    /// only the bin matching the piece accepts it.
    @discardableResult
    func place(pieceID: UUID) -> Bool {
        guard let trayIdx = tray.firstIndex(where: { $0.id == pieceID }) else { return false }
        let piece = tray[trayIdx]
        guard let binIdx = bins.firstIndex(where: { $0.kind == piece.kind }) else { return false }
        let placed = PlacedPiece(
            id: piece.id,
            kind: piece.kind,
            color: piece.color,
            offset: Self.softJitter(seed: bins[binIdx].placed.count + piece.id.hashValue)
        )
        bins[binIdx].placed.append(placed)
        tray.remove(at: trayIdx)
        return true
    }

    func reset() {
        bins = [
            Bin(id: .circle,   accent: \Palette.terracotta, labelKey: "shapeSortBinCircles",   placed: Self.initialCircles()),
            Bin(id: .square,   accent: \Palette.sage,       labelKey: "shapeSortBinSquares",   placed: Self.initialSquares()),
            Bin(id: .triangle, accent: \Palette.mustard,    labelKey: "shapeSortBinTriangles", placed: Self.initialTriangles())
        ]
        tray = [
            TrayPiece(id: UUID(), kind: .circle,   color: \Palette.terracotta),
            TrayPiece(id: UUID(), kind: .square,   color: \Palette.sage),
            TrayPiece(id: UUID(), kind: .triangle, color: \Palette.mustard),
            TrayPiece(id: UUID(), kind: .circle,   color: \Palette.terracotta),
            TrayPiece(id: UUID(), kind: .square,   color: \Palette.sage),
            TrayPiece(id: UUID(), kind: .triangle, color: \Palette.mustard)
        ]
    }

    static func softJitter(seed: Int) -> CGSize {
        // Deterministic offset so the same seed always produces the same nudge.
        let dx = Double((seed &* 1103515245 &+ 12345) % 60) - 30
        let dy = Double((seed &* 214013 &+ 2531011) % 36) - 18
        return CGSize(width: dx, height: dy)
    }

    private static func initialCircles() -> [PlacedPiece] {
        [
            PlacedPiece(id: UUID(), kind: .circle, color: \Palette.terracotta, offset: CGSize(width: -28, height: 22)),
            PlacedPiece(id: UUID(), kind: .circle, color: \Palette.terracotta, offset: CGSize(width: 24, height: 12))
        ]
    }

    private static func initialSquares() -> [PlacedPiece] {
        [
            PlacedPiece(id: UUID(), kind: .square, color: \Palette.sage, offset: CGSize(width: -8, height: 14))
        ]
    }

    private static func initialTriangles() -> [PlacedPiece] {
        [
            PlacedPiece(id: UUID(), kind: .triangle, color: \Palette.mustard, offset: CGSize(width: -36, height: 20)),
            PlacedPiece(id: UUID(), kind: .triangle, color: \Palette.mustard, offset: CGSize(width: 14, height: -8)),
            PlacedPiece(id: UUID(), kind: .triangle, color: \Palette.mustard, offset: CGSize(width: 48, height: 24))
        ]
    }
}
