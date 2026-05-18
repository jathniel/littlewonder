import SwiftUI

enum ShapeActivityID: String, CaseIterable, Hashable, Identifiable, Sendable {
    case match
    case sort
    case trace
    case build
    case freePlay

    var id: String { rawValue }

    var topic: TopicID { .shapes }

    var accent: KeyPath<Palette, Color> {
        switch self {
        case .match:    \Palette.terracotta
        case .sort:     \Palette.sage
        case .trace:    \Palette.oak
        case .build:    \Palette.mustard
        case .freePlay: \Palette.berry
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .match:    "shapeTileMatchTitle"
        case .sort:     "shapeTileSortTitle"
        case .trace:    "shapeTileTraceTitle"
        case .build:    "shapeTileBuildTitle"
        case .freePlay: "shapeTileFreePlayTitle"
        }
    }

    var subtitleKey: LocalizedStringKey {
        switch self {
        case .match:    "shapeTileMatchSubtitle"
        case .sort:     "shapeTileSortSubtitle"
        case .trace:    "shapeTileTraceSubtitle"
        case .build:    "shapeTileBuildSubtitle"
        case .freePlay: "shapeTileFreePlaySubtitle"
        }
    }

    var isWide: Bool { self == .freePlay }
}
