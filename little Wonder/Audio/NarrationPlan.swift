import Foundation

/// The testable decision half of narration: given the profile's narration settings and a
/// line of text, decides whether anything should be spoken and with which voice.
/// `NarrationService` turns a plan into an `AVSpeechUtterance`; everything here stays a
/// pure value so it can be unit-tested without a synthesizer.
struct NarrationPlan: Equatable, Sendable {
    /// What the synthesizer should say, trimmed of surrounding whitespace.
    let text: String
    /// BCP-47 code handed to `AVSpeechSynthesisVoice(language:)`.
    let voiceLanguage: String

    /// Slower than `AVSpeechUtteranceDefaultSpeechRate` (0.5) to match the app's calm pace.
    static let rate: Float = 0.42

    /// Returns `nil` when narration is switched off or there is nothing to say.
    static func make(saying text: String, isNarrationOn: Bool, language: NarrationLanguage) -> NarrationPlan? {
        guard isNarrationOn else { return nil }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return NarrationPlan(text: trimmed, voiceLanguage: language.voiceLanguage)
    }
}

extension NarrationLanguage {
    /// The synthesis voice for this narration language. The string catalog is English-only
    /// today, so es/fr speak English text with a localized voice until it is translated.
    var voiceLanguage: String {
        switch self {
        case .en: "en-US"
        case .es: "es-ES"
        case .fr: "fr-FR"
        }
    }
}
