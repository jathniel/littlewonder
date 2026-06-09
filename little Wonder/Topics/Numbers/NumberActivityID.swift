import SwiftUI

enum NumberActivityID: String, CaseIterable, Hashable, Identifiable, Sendable {
    case count
    case match
    case order
    case freePlay

    var id: String { rawValue }

    var topic: TopicID { .numbers }

    var accent: KeyPath<Palette, Color> {
        switch self {
        case .count:    \Palette.sky
        case .match:    \Palette.terracotta
        case .order:    \Palette.sage
        case .freePlay: \Palette.berry
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .count:    "numberTileCountTitle"
        case .match:    "numberTileMatchTitle"
        case .order:    "numberTileOrderTitle"
        case .freePlay: "numberTileFreePlayTitle"
        }
    }

    var subtitleKey: LocalizedStringKey {
        switch self {
        case .count:    "numberTileCountSubtitle"
        case .match:    "numberTileMatchSubtitle"
        case .order:    "numberTileOrderSubtitle"
        case .freePlay: "numberTileFreePlaySubtitle"
        }
    }

    var isWide: Bool { self == .freePlay }
}
