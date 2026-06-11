import CoreGraphics
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ShapeMatchViewModel {
    struct Piece: Identifiable {
        let id: String
        let kind: ShapeKind
        let color: KeyPath<Palette, Color>
        /// Center of the drop target in stage coordinates.
        let target: CGPoint
        /// Center of the tray slot the piece starts in.
        let traySlot: CGPoint
        /// Current center of the piece.
        var position: CGPoint
        var placed: Bool

        init(
            id: String,
            kind: ShapeKind,
            color: KeyPath<Palette, Color>,
            target: CGPoint,
            traySlot: CGPoint
        ) {
            self.id = id
            self.kind = kind
            self.color = color
            self.target = target
            self.traySlot = traySlot
            self.position = traySlot
            self.placed = false
        }
    }

    /// Logical canvas the design uses (1100 × 820); render scaled.
    static let canvasSize = CGSize(width: 1100, height: 820)
    static let pieceSize: CGFloat = 180
    static let snapRadius: CGFloat = 90

    static let eligibleKinds: [ShapeKind] = [
        .circle, .square, .triangle, .star, .heart, .diamond, .hexagon
    ]

    static let paletteOptions: [KeyPath<Palette, Color>] = [
        \Palette.terracotta, \Palette.oak, \Palette.sage,
        \Palette.sky, \Palette.berry, \Palette.plum, \Palette.mustard
    ]

    /// Target anchors arranged so a single 130pt piece never overlaps the next.
    static let targetAnchors: [CGPoint] = [
        CGPoint(x: 240, y: 240),
        CGPoint(x: 540, y: 240),
        CGPoint(x: 860, y: 240),
        CGPoint(x: 390, y: 480)
    ]

    private(set) var pieces: [Piece]
    private(set) var celebrate: Bool = false
    private var celebrationTask: Task<Void, Never>?

    /// Fires once when the round transitions from in-progress to complete.
    var onComplete: (() -> Void)?

    var placedCount: Int { pieces.count(where: \.placed) }
    var total: Int { pieces.count }
    var allPlaced: Bool { placedCount == total && total > 0 }

    init(pieces: [Piece]? = nil) {
        self.pieces = pieces ?? Self.randomPieces()
    }

    static func randomPieces() -> [Piece] {
        let pieceCount = Int.random(in: 3...4)
        let kinds = Array(eligibleKinds.shuffled().prefix(pieceCount))
        let colors = Array(paletteOptions.shuffled().prefix(pieceCount))
        let anchors = Array(targetAnchors.shuffled().prefix(pieceCount))

        let traySpacing: CGFloat = pieceSize + 40
        let trayWidth = traySpacing * CGFloat(pieceCount - 1)
        let trayStartX = (canvasSize.width - trayWidth) / 2
        let trayY: CGFloat = 720

        return (0..<pieceCount).map { idx in
            Piece(
                id: "\(kinds[idx].rawValue)-\(idx)",
                kind: kinds[idx],
                color: colors[idx],
                target: anchors[idx],
                traySlot: CGPoint(x: trayStartX + traySpacing * CGFloat(idx), y: trayY)
            )
        }
    }

    func updateDrag(_ id: String, to point: CGPoint) {
        guard let idx = pieces.firstIndex(where: { $0.id == id }), !pieces[idx].placed else { return }
        pieces[idx].position = point
    }

    /// Returns whether the drop landed on the piece's target.
    @discardableResult
    func endDrag(_ id: String) -> Bool {
        guard let idx = pieces.firstIndex(where: { $0.id == id }), !pieces[idx].placed else { return false }
        let snap = dragSnapResult(from: pieces[idx].position, to: pieces[idx].target, radius: Self.snapRadius)
        if snap.isInRange {
            pieces[idx].placed = true
            pieces[idx].position = pieces[idx].target
            if allPlaced {
                triggerCelebration()
            }
            return true
        } else {
            pieces[idx].position = pieces[idx].traySlot
            return false
        }
    }

    func reset() {
        celebrationTask?.cancel()
        celebrate = false
        pieces = Self.randomPieces()
    }

    private func triggerCelebration() {
        onComplete?()
        celebrate = true
        celebrationTask?.cancel()
        celebrationTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(2800))
            guard let self, !Task.isCancelled else { return }
            self.celebrate = false
        }
    }
}
