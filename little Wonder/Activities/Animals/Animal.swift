import SwiftUI

/// A nameable animal the child learns in the Animals room.
///
/// Each animal maps to an SF Symbol (its drawing) and a palette keypath (its token tint),
/// plus the `Habitat` it lives in — used by the Sort activity. Mirrors `ColorSwatch`'s role
/// in the Colours room: a stable identity used for both display and VoiceOver labels.
enum Animal: String, CaseIterable, Hashable, Identifiable, Sendable {
    case cat
    case dog
    case fish
    case bird
    case ant
    case ladybug
    case tortoise
    case hare
    case lizard

    var id: String { rawValue }

    /// SF Symbol used to draw the animal everywhere it appears.
    var symbol: String {
        switch self {
        case .cat:      "cat.fill"
        case .dog:      "dog.fill"
        case .fish:     "fish.fill"
        case .bird:     "bird.fill"
        case .ant:      "ant.fill"
        case .ladybug:  "ladybug.fill"
        case .tortoise: "tortoise.fill"
        case .hare:     "hare.fill"
        case .lizard:   "lizard.fill"
        }
    }

    /// Keypath into the active palette for this animal's token tint.
    var tint: KeyPath<Palette, Color> {
        switch self {
        case .cat:      \Palette.terracotta
        case .dog:      \Palette.oak
        case .fish:     \Palette.sky
        case .bird:     \Palette.plum
        case .ant:      \Palette.ink
        case .ladybug:  \Palette.berry
        case .tortoise: \Palette.sage
        case .hare:     \Palette.mustard
        case .lizard:   \Palette.sage
        }
    }

    /// Where this animal lives — the Sort activity's category.
    var habitat: Habitat {
        switch self {
        case .cat, .dog:        .pets
        case .ant, .ladybug:    .bugs
        case .fish, .tortoise:  .water
        case .bird, .hare, .lizard: .wild
        }
    }

    /// Localized animal name — shown to readers and spoken by VoiceOver.
    var nameKey: LocalizedStringKey {
        switch self {
        case .cat:      "animalNameCat"
        case .dog:      "animalNameDog"
        case .fish:     "animalNameFish"
        case .bird:     "animalNameBird"
        case .ant:      "animalNameAnt"
        case .ladybug:  "animalNameLadybug"
        case .tortoise: "animalNameTortoise"
        case .hare:     "animalNameHare"
        case .lizard:   "animalNameLizard"
        }
    }

    /// The animal name as a plain string, for narration.
    var localizedName: String {
        switch self {
        case .cat:      String(localized: "animalNameCat")
        case .dog:      String(localized: "animalNameDog")
        case .fish:     String(localized: "animalNameFish")
        case .bird:     String(localized: "animalNameBird")
        case .ant:      String(localized: "animalNameAnt")
        case .ladybug:  String(localized: "animalNameLadybug")
        case .tortoise: String(localized: "animalNameTortoise")
        case .hare:     String(localized: "animalNameHare")
        case .lizard:   String(localized: "animalNameLizard")
        }
    }
}
