import AVFoundation
import Observation

/// The app's calm voice: speaks prompts, item names, and celebration lines through
/// `AVSpeechSynthesizer`. All decisions (on/off gating, voice selection, pacing) live in
/// `NarrationPlan` so they stay testable; this class is the thin speaking shell.
@MainActor
@Observable
final class NarrationService {
    @ObservationIgnored private let synthesizer = AVSpeechSynthesizer()
    @ObservationIgnored private let profile: ProfileStore

    init(profile: ProfileStore) {
        self.profile = profile
        // Ambient so narration mixes with whatever a parent is already playing.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
    }

    /// Speaks `text`, replacing any utterance still in flight — children tap fast.
    func speak(_ text: String) {
        guard let plan = NarrationPlan.make(
            saying: text,
            isNarrationOn: profile.isNarrationOn,
            language: profile.narrationLanguage
        ) else { return }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: plan.text)
        utterance.rate = NarrationPlan.rate
        utterance.voice = AVSpeechSynthesisVoice(language: plan.voiceLanguage)
        synthesizer.speak(utterance)
    }
}
