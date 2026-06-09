import CoreGraphics
import Foundation
import Observation
import SwiftUI

/// Drag a numeral tile onto the card showing that many dots. Mirrors
/// `ShapeMatchViewModel`'s drag-snap mechanic, matching on a numeric value.
@MainActor
@Observable
final class NumberMatchViewModel {
    struct Piece: Identifiable {
        let id: String
        let value: Int
        let color: KeyPath<Palette, Color>
        /// Center of the drop target (dot card) in stage coordinates.
        let target: CGPoint
        /// Center of the tray slot the piece starts in.
        let traySlot: CGPoint
        var position: CGPoint
        var placed: Bool

        init(
            id: String,
            value: Int,
            color: KeyPath<Palette, Color>,
            target: CGPoint,
            traySlot: CGPoint
        ) {
            self.id = id
            self.value = value
            self.color = color
            self.target = target
            self.traySlot = traySlot
            self.position = traySlot
            self.placed = false
        }
    }

    static let canvasSize = CGSize(width: 1100, height: 820)
    static let pieceSize: CGFloat = 180
    static let snapRadius: CGFloat = 90

    static let eligibleValues: [Int] = [1, 2, 3, 4, 5]

    static let paletteOptions: [KeyPath<Palette, Color>] = [
        \Palette.terracotta, \Palette.oak, \Palette.sage,
        \Palette.sky, \Palette.berry, \Palette.plum, \Palette.mustard
    ]

    static let targetAnchors: [CGPoint] = [
        CGPoint(x: 240, y: 240),
        CGPoint(x: 540, y: 240),
        CGPoint(x: 860, y: 240),
        CGPoint(x: 390, y: 480)
    ]

    private(set) var pieces: [Piece]
    private(set) var celebrate: Bool = false
    private var celebrationTask: Task<Void, Never>?

    var onComplete: (() -> Void)?

    var placedCount: Int { pieces.lazy.filter(\.placed).count }
    var total: Int { pieces.count }
    var allPlaced: Bool { placedCount == total && total > 0 }

    init(pieces: [Piece]? = nil) {
        self.pieces = pieces ?? Self.randomPieces()
    }

    static func randomPieces() -> [Piece] {
        let pieceCount = Int.random(in: 3...4)
        let values = Array(eligibleValues.shuffled().prefix(pieceCount))
        let colors = Array(paletteOptions.shuffled().prefix(pieceCount))
        let anchors = Array(targetAnchors.shuffled().prefix(pieceCount))

        let traySpacing: CGFloat = pieceSize + 40
        let trayWidth = traySpacing * CGFloat(pieceCount - 1)
        let trayStartX = (canvasSize.width - trayWidth) / 2
        let trayY: CGFloat = 720

        return (0..<pieceCount).map { idx in
            Piece(
                id: "\(values[idx])-\(idx)",
                value: values[idx],
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
