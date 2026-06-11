import SwiftUI

enum AnimalActivityID: String, CaseIterable, Hashable, Identifiable, Sendable {
    case match
    case sort
    case find
    case freePlay

    var id: String { rawValue }

    var topic: TopicID { .animals }

    var accent: KeyPath<Palette, Color> {
        switch self {
        case .match:    \Palette.sage
        case .sort:     \Palette.oak
        case .find:     \Palette.sky
        case .freePlay: \Palette.terracotta
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .match:    "animalTileMatchTitle"
        case .sort:     "animalTileSortTitle"
        case .find:     "animalTileFindTitle"
        case .freePlay: "animalTileFreePlayTitle"
        }
    }

    var subtitleKey: LocalizedStringKey {
        switch self {
        case .match:    "animalTileMatchSubtitle"
        case .sort:     "animalTileSortSubtitle"
        case .find:     "animalTileFindSubtitle"
        case .freePlay: "animalTileFreePlaySubtitle"
        }
    }

    var isWide: Bool { self == .freePlay }
}
