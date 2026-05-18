import Foundation

enum ActivityID: String, CaseIterable, Hashable, Identifiable, Sendable {
    case shapeMatch

    var id: String { rawValue }
}
