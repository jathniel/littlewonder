import Foundation
import Observation
import SwiftUI

/// Mix two primary colours to make the target secondary. Each round names a target
/// secondary ("Make orange"); the child taps two of the three primary pots and the
/// mixing well shows the result. A correct mix solves the round; a wrong mix simply
/// shows its (different) colour with no fail state. Tap-two-→-result mechanic.
@MainActor
@Observable
final class ColorMixViewModel {
    /// The three primary pots the child can tap.
    let pots: [ColorSwatch] = ColorSwatch.primaries

    /// One target secondary per round.
    let targets: [ColorSwatch]

    private(set) var roundIndex: Int
    private(set) var selection: [ColorSwatch]
    private(set) var solvedRound: Bool
    private(set) var celebrate: Bool = false
    private var celebrationTask: Task<Void, Never>?

    /// Fires once when the final round is solved.
    var onComplete: (() -> Void)?

    var totalRounds: Int { targets.count }
    var target: ColorSwatch { targets[roundIndex] }
    var isLastRound: Bool { roundIndex == targets.count - 1 }
    /// Drives `ProgressDots` — number of solved rounds.
    var completedRounds: Int { roundIndex + (solvedRound ? 1 : 0) }

    /// The colour currently in the mixing well, once two distinct primaries are chosen.
    var result: ColorSwatch? {
        guard selection.count == 2 else { return nil }
        return ColorSwatch.mix(selection[0], selection[1])
    }

    func isSelected(_ swatch: ColorSwatch) -> Bool { selection.contains(swatch) }

    init(targets: [ColorSwatch]? = nil) {
        self.targets = targets ?? ColorSwatch.secondaries.shuffled()
        self.roundIndex = 0
        self.selection = []
        self.solvedRound = false
    }

    /// Taps a primary pot. Toggles selection; a third tap (after two are chosen)
    /// restarts the mix with the new colour. A correct mix solves the round.
    func tap(_ primary: ColorSwatch) {
        guard primary.isPrimary, !solvedRound else { return }

        if selection.count == 2 {
            // The well is already showing a result — start a fresh mix.
            selection = [primary]
            return
        }
        if let idx = selection.firstIndex(of: primary) {
            selection.remove(at: idx)
            return
        }
        selection.append(primary)

        if selection.count == 2, result == target {
            solvedRound = true
            if isLastRound {
                triggerCelebration()
            }
        }
    }

    /// Advances to the next round once the current one is solved.
    func advanceRound() {
        guard solvedRound, !isLastRound else { return }
        roundIndex += 1
        selection = []
        solvedRound = false
    }

    func reset() {
        celebrationTask?.cancel()
        celebrate = false
        roundIndex = 0
        selection = []
        solvedRound = false
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
