import CoreGraphics
import Foundation
import Observation
import SwiftUI

/// Drag a colour chip onto the outlined frame of the same colour. Mirrors
/// `NumberMatchViewModel`'s drag-snap mechanic, matching on `ColorSwatch`.
@MainActor
@Observable
final class ColorMatchViewModel {
    struct Piece: Identifiable {
        let id: String
        let swatch: ColorSwatch
        /// Center of the drop target (outlined frame) in stage coordinates.
        let target: CGPoint
        /// Center of the tray slot the piece starts in.
        let traySlot: CGPoint
        var position: CGPoint
        var placed: Bool

        init(id: String, swatch: ColorSwatch, target: CGPoint, traySlot: CGPoint) {
            self.id = id
            self.swatch = swatch
            self.target = target
            self.traySlot = traySlot
            self.position = traySlot
            self.placed = false
        }
    }

    static let canvasSize = CGSize(width: 1100, height: 820)
    static let pieceSize: CGFloat = 180
    static let snapRadius: CGFloat = 90

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
        // Distinct colours so each target's position maps unambiguously to one colour.
        let swatches = Array(ColorSwatch.allCases.shuffled().prefix(pieceCount))
        let anchors = Array(targetAnchors.shuffled().prefix(pieceCount))

        let traySpacing: CGFloat = pieceSize + 40
        let trayWidth = traySpacing * CGFloat(pieceCount - 1)
        let trayStartX = (canvasSize.width - trayWidth) / 2
        let trayY: CGFloat = 720

        // Shuffle which tray slot each chip starts in, so chip order != target order.
        let traySlots = (0..<pieceCount).map { CGPoint(x: trayStartX + traySpacing * CGFloat($0), y: trayY) }.shuffled()

        return (0..<pieceCount).map { idx in
            Piece(
                id: "\(swatches[idx].rawValue)-\(idx)",
                swatch: swatches[idx],
                target: anchors[idx],
                traySlot: traySlots[idx]
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
