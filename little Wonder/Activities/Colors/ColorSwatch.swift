import SwiftUI

/// A nameable color the child learns in the Colors room.
///
/// Each swatch maps to a palette keypath so the whole room re-tints with the active
/// theme, while keeping a stable identity used for both display and VoiceOver labels.
/// Colours are deliberately *named* everywhere they appear so the activities never rely
/// on hue alone — important for colour-blind and VoiceOver users.
enum ColorSwatch: String, CaseIterable, Hashable, Identifiable, Sendable {
    case red
    case yellow
    case blue
    case green
    case orange
    case purple

    var id: String { rawValue }

    /// Keypath into the active palette for this swatch's fill.
    var fill: KeyPath<Palette, Color> {
        switch self {
        case .red:    \Palette.berry
        case .yellow: \Palette.mustard
        case .blue:   \Palette.sky
        case .green:  \Palette.sage
        case .orange: \Palette.terracotta
        case .purple: \Palette.plum
        }
    }

    /// Localized colour name — shown to readers and spoken by VoiceOver.
    var nameKey: LocalizedStringKey {
        switch self {
        case .red:    "colorNameRed"
        case .yellow: "colorNameYellow"
        case .blue:   "colorNameBlue"
        case .green:  "colorNameGreen"
        case .orange: "colorNameOrange"
        case .purple: "colorNamePurple"
        }
    }

    /// The colour name as a plain string, for narration.
    var localizedName: String {
        switch self {
        case .red:    String(localized: "colorNameRed")
        case .yellow: String(localized: "colorNameYellow")
        case .blue:   String(localized: "colorNameBlue")
        case .green:  String(localized: "colorNameGreen")
        case .orange: String(localized: "colorNameOrange")
        case .purple: String(localized: "colorNamePurple")
        }
    }

    var isPrimary: Bool {
        switch self {
        case .red, .yellow, .blue: true
        default: false
        }
    }

    var isSecondary: Bool { !isPrimary }

    static let primaries: [ColorSwatch] = [.red, .yellow, .blue]
    static let secondaries: [ColorSwatch] = [.orange, .green, .purple]

    /// Subtractive paint mixing of two distinct primaries.
    /// red + yellow → orange, blue + yellow → green, red + blue → purple.
    /// Order-independent; returns `nil` for the same colour twice or any pair that
    /// isn't two primaries.
    static func mix(_ a: ColorSwatch, _ b: ColorSwatch) -> ColorSwatch? {
        guard a != b, a.isPrimary, b.isPrimary else { return nil }
        let pair: Set<ColorSwatch> = [a, b]
        if pair == [.red, .yellow] { return .orange }
        if pair == [.blue, .yellow] { return .green }
        if pair == [.red, .blue] { return .purple }
        return nil
    }

    /// The two primaries that mix to this secondary, if any.
    var mixIngredients: (ColorSwatch, ColorSwatch)? {
        switch self {
        case .orange: (.red, .yellow)
        case .green:  (.blue, .yellow)
        case .purple: (.red, .blue)
        default:      nil
        }
    }
}
