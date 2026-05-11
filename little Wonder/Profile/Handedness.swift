import SwiftUI

enum Handedness: String, CaseIterable, Hashable, Sendable, Identifiable {
    case left
    case right

    var id: String { rawValue }

    var displayKey: LocalizedStringKey {
        switch self {
        case .left:  "handednessLeft"
        case .right: "handednessRight"
        }
    }

    var localized: String {
        switch self {
        case .left:  String(localized: "handednessLeft")
        case .right: String(localized: "handednessRight")
        }
    }
}
