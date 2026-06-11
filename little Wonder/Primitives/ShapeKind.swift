import SwiftUI

enum ShapeKind: String, CaseIterable, Hashable, Sendable {
    case circle
    case square
    case rectangle
    case triangle
    case oval
    case hexagon
    case star
    case heart
    case diamond
    case semicircle

    /// Localized shape name — shown to readers and spoken by VoiceOver.
    var nameKey: LocalizedStringKey {
        switch self {
        case .circle:     "shapeKindCircle"
        case .square:     "shapeKindSquare"
        case .rectangle:  "shapeKindRectangle"
        case .triangle:   "shapeKindTriangle"
        case .oval:       "shapeKindOval"
        case .hexagon:    "shapeKindHexagon"
        case .star:       "shapeKindStar"
        case .heart:      "shapeKindHeart"
        case .diamond:    "shapeKindDiamond"
        case .semicircle: "shapeKindSemicircle"
        }
    }

    /// The shape name as a plain string, for narration.
    var localizedName: String {
        switch self {
        case .circle:     String(localized: "shapeKindCircle")
        case .square:     String(localized: "shapeKindSquare")
        case .rectangle:  String(localized: "shapeKindRectangle")
        case .triangle:   String(localized: "shapeKindTriangle")
        case .oval:       String(localized: "shapeKindOval")
        case .hexagon:    String(localized: "shapeKindHexagon")
        case .star:       String(localized: "shapeKindStar")
        case .heart:      String(localized: "shapeKindHeart")
        case .diamond:    String(localized: "shapeKindDiamond")
        case .semicircle: String(localized: "shapeKindSemicircle")
        }
    }
}
