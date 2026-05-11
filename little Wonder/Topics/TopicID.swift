import SwiftUI

enum TopicID: String, CaseIterable, Hashable, Identifiable, Sendable {
    case shapes
    case numbers
    case animals
    case colors
    case letters
    case feelings

    var id: String { rawValue }

    /// Keypath into the active palette for this topic's accent color.
    var accent: KeyPath<Palette, Color> {
        switch self {
        case .shapes:   \Palette.shapes
        case .numbers:  \Palette.numbers
        case .animals:  \Palette.animals
        case .colors:   \Palette.colors
        case .letters:  \Palette.plum
        case .feelings: \Palette.berry
        }
    }
}
