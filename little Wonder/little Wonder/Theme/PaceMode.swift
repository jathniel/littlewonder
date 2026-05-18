import Foundation

enum PaceMode: String, Codable, CaseIterable, Identifiable {
    case slow
    case playful

    var id: String { rawValue }

    var pace: Pace {
        switch self {
        case .slow: .slow
        case .playful: .playful
        }
    }
}
