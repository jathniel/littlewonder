import Foundation
import Observation
import SwiftUI

/// Tap-to-count: each round shows a cluster of objects; the child taps every one to
/// count it. Finishing the last round triggers the celebration. No fail state.
@MainActor
@Observable
final class NumberCountViewModel {
    struct Item: Identifiable {
        let id: Int
        var counted: Bool
    }

    /// One count target per round.
    let roundCounts: [Int]

    private(set) var roundIndex: Int
    private(set) var items: [Item]
    private(set) var celebrate: Bool = false
    private var celebrationTask: Task<Void, Never>?

    /// Fires once when the final round is completed.
    var onComplete: (() -> Void)?

    var totalRounds: Int { roundCounts.count }
    var currentCount: Int { roundCounts[roundIndex] }
    var countedCount: Int { items.lazy.filter(\.counted).count }
    var roundComplete: Bool { countedCount == items.count && !items.isEmpty }
    var isLastRound: Bool { roundIndex == roundCounts.count - 1 }
    /// Drives `ProgressDots` — number of fully finished rounds.
    var completedRounds: Int { roundIndex + (roundComplete ? 1 : 0) }

    init(roundCounts: [Int]? = nil) {
        let resolved = roundCounts ?? Self.randomRounds()
        self.roundCounts = resolved
        self.roundIndex = 0
        self.items = Self.makeItems(count: resolved[0])
    }

    static func randomRounds() -> [Int] {
        (0..<3).map { _ in Int.random(in: 2...6) }
    }

    static func makeItems(count: Int) -> [Item] {
        (0..<count).map { Item(id: $0, counted: false) }
    }

    /// Counts the tapped item. Completing the last round celebrates.
    func tap(_ id: Int) {
        guard let idx = items.firstIndex(where: { $0.id == id }), !items[idx].counted else { return }
        items[idx].counted = true
        if roundComplete, isLastRound {
            triggerCelebration()
        }
    }

    /// Advances to the next round once the current one is complete.
    func advanceRound() {
        guard roundComplete, !isLastRound else { return }
        roundIndex += 1
        items = Self.makeItems(count: currentCount)
    }

    func reset() {
        celebrationTask?.cancel()
        celebrate = false
        roundIndex = 0
        items = Self.makeItems(count: roundCounts[0])
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
