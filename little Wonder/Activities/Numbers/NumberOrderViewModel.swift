import Foundation
import Observation
import SwiftUI

/// Line numbers up 1→N. Numerals start shuffled in a tray; tapping the next number
/// in sequence drops it into its slot. No fail state — a wrong tap is ignored.
@MainActor
@Observable
final class NumberOrderViewModel {
    struct TrayNumber: Identifiable {
        let id: UUID
        let value: Int
        let color: KeyPath<Palette, Color>
    }

    static let paletteOptions: [KeyPath<Palette, Color>] = [
        \Palette.terracotta, \Palette.oak, \Palette.sage,
        \Palette.sky, \Palette.berry, \Palette.plum, \Palette.mustard
    ]

    let sequence: [Int]
    /// Positional slots; `slots[i]` holds `sequence[i]` once placed, else `nil`.
    private(set) var slots: [Int?]
    private(set) var tray: [TrayNumber]
    private(set) var celebrate: Bool = false
    private var celebrationTask: Task<Void, Never>?

    var onComplete: (() -> Void)?

    var placedCount: Int { slots.lazy.compactMap { $0 }.count }
    var total: Int { sequence.count }
    var allPlaced: Bool { placedCount == total }
    /// The value the next empty slot expects, or `nil` when complete.
    var nextExpected: Int? { placedCount < total ? sequence[placedCount] : nil }

    init(sequence: [Int] = Array(1...5), shuffle: Bool = true) {
        self.sequence = sequence
        self.slots = Array(repeating: nil, count: sequence.count)
        self.tray = Self.makeTray(sequence: sequence, shuffle: shuffle)
    }

    private static func makeTray(sequence: [Int], shuffle: Bool) -> [TrayNumber] {
        let colors = paletteOptions
        let ordered = sequence.enumerated().map { idx, value in
            TrayNumber(id: UUID(), value: value, color: colors[idx % colors.count])
        }
        return shuffle ? ordered.shuffled() : ordered
    }

    /// Places `value` into the next slot when it is the expected number.
    @discardableResult
    func place(_ value: Int) -> Bool {
        guard value == nextExpected, let trayIdx = tray.firstIndex(where: { $0.value == value }) else { return false }
        slots[placedCount] = value
        tray.remove(at: trayIdx)
        if allPlaced {
            triggerCelebration()
        }
        return true
    }

    func reset() {
        celebrationTask?.cancel()
        celebrate = false
        slots = Array(repeating: nil, count: sequence.count)
        tray = Self.makeTray(sequence: sequence, shuffle: true)
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
