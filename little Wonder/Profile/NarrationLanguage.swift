import SwiftUI

enum NarrationLanguage: String, CaseIterable, Hashable, Sendable, Identifiable {
    case en
    case es
    case fr

    var id: String { rawValue }

    var displayKey: LocalizedStringKey {
        switch self {
        case .en: "narrationEnglish"
        case .es: "narrationSpanish"
        case .fr: "narrationFrench"
        }
    }

    var localized: String {
        switch self {
        case .en: String(localized: "narrationEnglish")
        case .es: String(localized: "narrationSpanish")
        case .fr: String(localized: "narrationFrench")
        }
    }
}
