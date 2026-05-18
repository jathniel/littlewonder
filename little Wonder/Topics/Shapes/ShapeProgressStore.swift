import Foundation
import Observation
import SwiftUI

/// Tracks weekly activity counts for the Shape Room hub.
/// In-memory for v1 — TODO: back with SwiftData once a `ShapeWeeklyLog` model lands.
@MainActor
@Observable
final class ShapeProgressStore {
    private(set) var matchesMadeThisWeek: Int
    /// Sunday … Saturday — `true` when any activity completed that day.
    private(set) var weekActivity: [Bool]

    init(matchesMadeThisWeek: Int = 12, weekActivity: [Bool] = [true, true, true, true, false, true, true]) {
        self.matchesMadeThisWeek = matchesMadeThisWeek
        self.weekActivity = weekActivity
    }

    func recordMatch() {
        matchesMadeThisWeek += 1
        markToday()
    }

    func recordSort()  { markToday() }
    func recordTrace() { markToday() }
    func recordBuild() { markToday() }

    private func markToday() {
        let weekday = Calendar.current.component(.weekday, from: .now) - 1
        guard weekActivity.indices.contains(weekday) else { return }
        weekActivity[weekday] = true
    }
}
