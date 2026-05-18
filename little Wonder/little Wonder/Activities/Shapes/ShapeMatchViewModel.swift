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
    static let pieceSize: CGFloat = 130

    private(set) var pieces: [Piece]
    private(set) var celebrate: Bool = false
    private var celebrationTask: Task<Void, Never>?

    var placedCount: Int { pieces.lazy.filter(\.placed).count }
    var total: Int { pieces.count }
    var allPlaced: Bool { placedCount == total && total > 0 }

    init(pieces: [Piece]? = nil) {
        self.pieces = pieces ?? Self.defaultPieces()
    }

    static func defaultPieces() -> [Piece] {
        [
            Piece(id: "circle",
                  kind: .circle,
                  color: \Palette.terracotta,
                  target: CGPoint(x: 240, y: 240),
                  traySlot: CGPoint(x: 80 + pieceSize / 2, y: 720)),
            Piece(id: "square",
                  kind: .square,
                  color: \Palette.oak,
                  target: CGPoint(x: 540, y: 240),
                  traySlot: CGPoint(x: 250 + pieceSize / 2, y: 720)),
            Piece(id: "triangle",
                  kind: .triangle,
                  color: \Palette.sage,
                  target: CGPoint(x: 390, y: 460),
                  traySlot: CGPoint(x: 420 + pieceSize / 2, y: 720))
        ]
    }

    func updateDrag(_ id: String, to point: CGPoint) {
        guard let idx = pieces.firstIndex(where: { $0.id == id }), !pieces[idx].placed else { return }
        pieces[idx].position = point
    }

    /// Returns whether the drop landed on the piece's target.
    @discardableResult
    func endDrag(_ id: String) -> Bool {
        guard let idx = pieces.firstIndex(where: { $0.id == id }), !pieces[idx].placed else { return false }
        let snap = dragSnapResult(from: pieces[idx].position, to: pieces[idx].target)
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
        for idx in pieces.indices {
            pieces[idx].position = pieces[idx].traySlot
            pieces[idx].placed = false
        }
    }

    private func triggerCelebration() {
        celebrate = true
        celebrationTask?.cancel()
        celebrationTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(2800))
            guard let self, !Task.isCancelled else { return }
            self.celebrate = false
        }
    }
}
