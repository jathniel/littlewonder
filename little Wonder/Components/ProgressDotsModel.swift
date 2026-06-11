import Foundation

/// Display logic for `ProgressDots`. Callers pass `active` as a completed count,
/// which can equal `count` when an activity is finished — clamping keeps the
/// highlight on the last dot and the announced step within `1...count`.
struct ProgressDotsModel: Equatable {
    let count: Int
    let active: Int

    /// Index of the dot drawn in the highlighted style.
    var highlightedIndex: Int {
        min(active, count - 1)
    }

    /// 1-based step announced to VoiceOver, never exceeding `count`.
    var stepNumber: Int {
        min(active + 1, count)
    }
}
