import Foundation
import Observation
import SwiftUI

/// Find every chip of the named colour. Each round names a target colour and shows a
/// field of chips mixing that colour with distractors; the child taps every matching
/// chip. Tapping a distractor is ignored (no fail state). Mirrors `NumberCountViewModel`'s
/// round structure.
@MainActor
@Observable
final class ColorFindViewModel {
    struct Item: Identifiable {
        let id: Int
        let swatch: ColorSwatch
        var found: Bool
    }

    /// One target colour per round.
    let targets: [ColorSwatch]
    private let fixedRounds: [[ColorSwatch]]?

    private(set) var roundIndex: Int
    private(set) var items: [Item]
    private(set) var celebrate: Bool = false
    private var celebrationTask: Task<Void, Never>?

    /// Fires once when the final round is completed.
    var onComplete: (() -> Void)?

    var totalRounds: Int { targets.count }
    var target: ColorSwatch { targets[roundIndex] }
    var matchTotal: Int { items.lazy.filter { $0.swatch == self.target }.count }
    var foundCount: Int { items.lazy.filter(\.found).count }
    var roundComplete: Bool { foundCount == matchTotal && matchTotal > 0 }
    var isLastRound: Bool { roundIndex == targets.count - 1 }
    /// Drives `ProgressDots` — number of fully finished rounds.
    var completedRounds: Int { roundIndex + (roundComplete ? 1 : 0) }

    init(targets: [ColorSwatch]? = nil, rounds: [[ColorSwatch]]? = nil) {
        let resolvedTargets = targets ?? Array(ColorSwatch.allCases.shuffled().prefix(3))
        self.targets = resolvedTargets
        self.fixedRounds = rounds
        self.roundIndex = 0
        self.items = Self.makeItems(target: resolvedTargets[0], fixed: rounds?.first)
    }

    static func makeItems(target: ColorSwatch, fixed: [ColorSwatch]?) -> [Item] {
        let swatches: [ColorSwatch]
        if let fixed {
            swatches = fixed
        } else {
            let matchCount = Int.random(in: 2...4)
            let others = ColorSwatch.allCases.filter { $0 != target }
            let distractorCount = Int.random(in: 3...5)
            var pool = Array(repeating: target, count: matchCount)
            pool += (0..<distractorCount).compactMap { _ in others.randomElement() }
            swatches = pool.shuffled()
        }
        return swatches.enumerated().map { Item(id: $0.offset, swatch: $0.element, found: false) }
    }

    /// Marks a matching chip found. Tapping a distractor is ignored. Completing the
    /// last round celebrates.
    func tap(_ id: Int) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        guard items[idx].swatch == target, !items[idx].found else { return }
        items[idx].found = true
        if roundComplete, isLastRound {
            triggerCelebration()
        }
    }

    /// Advances to the next round once the current one is complete.
    func advanceRound() {
        guard roundComplete, !isLastRound else { return }
        roundIndex += 1
        items = Self.makeItems(target: target, fixed: fixedRounds?[safe: roundIndex])
    }

    func reset() {
        celebrationTask?.cancel()
        celebrate = false
        roundIndex = 0
        items = Self.makeItems(target: targets[0], fixed: fixedRounds?.first)
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

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
