import SwiftUI

enum AvatarColor: String, CaseIterable, Hashable, Sendable, Identifiable {
    case terracotta
    case sage
    case mustard
    case sky
    case berry
    case plum

    var id: String { rawValue }

    func color(in palette: Palette) -> Color {
        switch self {
        case .terracotta: palette.terracotta
        case .sage:       palette.sage
        case .mustard:    palette.mustard
        case .sky:        palette.sky
        case .berry:      palette.berry
        case .plum:       palette.plum
        }
    }
}
