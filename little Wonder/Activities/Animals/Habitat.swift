import SwiftUI

/// A place an animal lives — the sorting category in the Animals room.
///
/// Each habitat maps to an SF Symbol icon and a palette keypath so the bins re-tint with
/// the active theme. Habitats are *named* everywhere they appear so the Sort activity never
/// relies on icon or colour alone — important for colour-blind and VoiceOver users.
enum Habitat: String, CaseIterable, Hashable, Identifiable, Sendable {
    case pets
    case bugs
    case water
    case wild

    var id: String { rawValue }

    /// SF Symbol shown as the bin's habitat icon.
    var symbol: String {
        switch self {
        case .pets:  "house.fill"
        case .bugs:  "leaf.fill"
        case .water: "drop.fill"
        case .wild:  "tree.fill"
        }
    }

    /// Keypath into the active palette for this habitat's accent.
    var accent: KeyPath<Palette, Color> {
        switch self {
        case .pets:  \Palette.terracotta
        case .bugs:  \Palette.sage
        case .water: \Palette.sky
        case .wild:  \Palette.oak
        }
    }

    /// Localized habitat name — shown to readers and spoken by VoiceOver.
    var nameKey: LocalizedStringKey {
        switch self {
        case .pets:  "habitatNamePets"
        case .bugs:  "habitatNameBugs"
        case .water: "habitatNameWater"
        case .wild:  "habitatNameWild"
        }
    }

    /// The animals that live in this habitat.
    var animals: [Animal] {
        Animal.allCases.filter { $0.habitat == self }
    }
}
