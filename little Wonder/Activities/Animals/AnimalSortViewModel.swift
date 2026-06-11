import CoreGraphics
import Foundation
import Observation
import SwiftUI

/// Sort animals into the bin of the habitat they live in. Unlike `ColorSortViewModel`
/// (which keys bins by *identity* — a bin is a swatch), this keys bins by *category*: a bin
/// is a `Habitat`, each tray piece is a distinct `Animal`, and a piece snaps where
/// `bin.habitat == piece.animal.habitat`. Records completion + celebrates when the tray empties.
@MainActor
@Observable
final class AnimalSortViewModel {
    struct Bin: Identifiable {
        let id: Habitat
        var placed: [PlacedPiece]

        var habitat: Habitat { id }
    }

    struct PlacedPiece: Identifiable {
        let id: UUID
        let animal: Animal
        /// Position inside the bin, in the bin's local coordinate space.
        let offset: CGSize
    }

    struct TrayPiece: Identifiable {
        let id: UUID
        let animal: Animal
    }

    private(set) var bins: [Bin]
    private(set) var tray: [TrayPiece]
    private(set) var celebrate: Bool = false
    private var celebrationTask: Task<Void, Never>?

    var onComplete: (() -> Void)?

    let habitats: [Habitat]
    let perHabitat: Int

    var remaining: Int { tray.count }
    var total: Int { tray.count + bins.reduce(0) { $0 + $1.placed.count } }
    var allSorted: Bool { tray.isEmpty && total > 0 }

    /// `habitats` defaults to three randomly-chosen habitats that each have at least
    /// `perHabitat` distinct animals, so the tray can always be filled with varied animals.
    init(habitats: [Habitat]? = nil, perHabitat: Int = 2, shuffle: Bool = true) {
        let resolved = habitats ?? Self.randomHabitats(perHabitat: perHabitat)
        self.habitats = resolved
        self.perHabitat = perHabitat
        self.bins = resolved.map { Bin(id: $0, placed: []) }
        self.tray = Self.makeTray(habitats: resolved, perHabitat: perHabitat, shuffle: shuffle)
    }

    static func randomHabitats(perHabitat: Int, count: Int = 3) -> [Habitat] {
        let eligible = Habitat.allCases.filter { $0.animals.count >= perHabitat }
        return Array(eligible.shuffled().prefix(count))
    }

    private static func makeTray(habitats: [Habitat], perHabitat: Int, shuffle: Bool) -> [TrayPiece] {
        let pieces = habitats.flatMap { habitat -> [TrayPiece] in
            let animals = shuffle ? habitat.animals.shuffled() : habitat.animals
            return animals.prefix(perHabitat).map { TrayPiece(id: UUID(), animal: $0) }
        }
        return shuffle ? pieces.shuffled() : pieces
    }

    /// Snap a tray piece into the bin whose habitat the animal lives in. No fail state, so
    /// only the matching habitat bin accepts it.
    @discardableResult
    func place(pieceID: UUID) -> Bool {
        guard let trayIdx = tray.firstIndex(where: { $0.id == pieceID }) else { return false }
        let piece = tray[trayIdx]
        guard let binIdx = bins.firstIndex(where: { $0.habitat == piece.animal.habitat }) else { return false }
        let placed = PlacedPiece(
            id: piece.id,
            animal: piece.animal,
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
        bins = habitats.map { Bin(id: $0, placed: []) }
        tray = Self.makeTray(habitats: habitats, perHabitat: perHabitat, shuffle: true)
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
