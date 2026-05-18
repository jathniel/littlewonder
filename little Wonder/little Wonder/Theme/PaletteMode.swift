import Foundation

enum PaletteMode: String, Codable, CaseIterable, Identifiable {
    case warm
    case cool
    case neutral

    var id: String { rawValue }

    var palette: Palette {
        switch self {
        case .warm: .warm
        case .cool: .cool
        case .neutral: .neutral
        }
    }
}
