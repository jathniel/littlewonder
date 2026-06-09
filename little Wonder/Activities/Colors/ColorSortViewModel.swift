import CoreGraphics
import Foundation
import Observation
import SwiftUI

/// Sort colour chips into the bin of the matching colour. Mirrors `ShapeSortViewModel`'s
/// bin mechanic, but — unlike Shapes — records completion + celebrates when the tray is
/// empty, matching the Number room's scoring pattern.
@MainActor
@Observable
final class ColorSortViewModel {
    struct Bin: Identifiable {
        let id: ColorSwatch
        var placed: [PlacedPiece]

        var swatch: ColorSwatch { id }
    }

    struct PlacedPiece: Identifiable {
        let id: UUID
        let swatch: ColorSwatch
        /// Position inside the bin, in the bin's local coordinate space.
        let offset: CGSize
    }

    struct TrayPiece: Identifiable {
        let id: UUID
        let swatch: ColorSwatch
    }

    private(set) var bins: [Bin]
    private(set) var tray: [TrayPiece]
    private(set) var celebrate: Bool = false
    private var celebrationTask: Task<Void, Never>?

    var onComplete: (() -> Void)?

    let colors: [ColorSwatch]
    let perColor: Int

    var remaining: Int { tray.count }
    var total: Int { tray.count + bins.reduce(0) { $0 + $1.placed.count } }
    var allSorted: Bool { tray.isEmpty && total > 0 }

    init(colors: [ColorSwatch]? = nil, perColor: Int = 2, shuffle: Bool = true) {
        let resolved = colors ?? Array(ColorSwatch.allCases.shuffled().prefix(3))
        self.colors = resolved
        self.perColor = perColor
        self.bins = resolved.map { Bin(id: $0, placed: []) }
        self.tray = Self.makeTray(colors: resolved, perColor: perColor, shuffle: shuffle)
    }

    private static func makeTray(colors: [ColorSwatch], perColor: Int, shuffle: Bool) -> [TrayPiece] {
        let pieces = colors.flatMap { color in
            (0..<perColor).map { _ in TrayPiece(id: UUID(), swatch: color) }
        }
        return shuffle ? pieces.shuffled() : pieces
    }

    /// Snap any tray piece into the matching bin — no fail state, so only the bin
    /// matching the piece's colour accepts it.
    @discardableResult
    func place(pieceID: UUID) -> Bool {
        guard let trayIdx = tray.firstIndex(where: { $0.id == pieceID }) else { return false }
        let piece = tray[trayIdx]
        guard let binIdx = bins.firstIndex(where: { $0.swatch == piece.swatch }) else { return false }
        let placed = PlacedPiece(
            id: piece.id,
            swatch: piece.swatch,
            offset: Self.softJitter(seed: bins[binIdx].placed.count + piece.id.hashValue)
        )
        bins[binIdx].placed.append(placed)
        tray.remove(at: trayIdx)
        if allSorted {
            triggerCelebration()
        }
        return true
    }

    func reset() {
        celebrationTask?.cancel()
        celebrate = false
        bins = colors.map { Bin(id: $0, placed: []) }
        tray = Self.makeTray(colors: colors, perColor: perColor, shuffle: true)
    }

    static func softJitter(seed: Int) -> CGSize {
        // Deterministic offset so the same seed always produces the same nudge.
        let dx = Double((seed &* 1103515245 &+ 12345) % 60) - 30
        let dy = Double((seed &* 214013 &+ 2531011) % 36) - 18
        return CGSize(width: dx, height: dy)
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
