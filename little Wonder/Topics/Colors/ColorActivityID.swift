import SwiftUI

enum ColorActivityID: String, CaseIterable, Hashable, Identifiable, Sendable {
    case match
    case sort
    case find
    case mix
    case freePlay

    var id: String { rawValue }

    var topic: TopicID { .colors }

    var accent: KeyPath<Palette, Color> {
        switch self {
        case .match:    \Palette.berry
        case .sort:     \Palette.sky
        case .find:     \Palette.sage
        case .mix:      \Palette.terracotta
        case .freePlay: \Palette.plum
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .match:    "colorTileMatchTitle"
        case .sort:     "colorTileSortTitle"
        case .find:     "colorTileFindTitle"
        case .mix:      "colorTileMixTitle"
        case .freePlay: "colorTileFreePlayTitle"
        }
    }

    var subtitleKey: LocalizedStringKey {
        switch self {
        case .match:    "colorTileMatchSubtitle"
        case .sort:     "colorTileSortSubtitle"
        case .find:     "colorTileFindSubtitle"
        case .mix:      "colorTileMixSubtitle"
        case .freePlay: "colorTileFreePlaySubtitle"
        }
    }

    var isWide: Bool { self == .freePlay }
}
