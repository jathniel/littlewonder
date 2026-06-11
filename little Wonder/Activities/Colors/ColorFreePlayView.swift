import SwiftUI

struct ColorFreePlayView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NarrationService.self) private var narration
    @State private var viewModel = ColorStampViewModel()

    var body: some View {
        ActivityStage(
            kicker: "colorFreePlayKicker",
            title: "colorFreePlayTitle",
            prompt: nil,
            progress: ProgressDots(count: 3, active: min(viewModel.pieceCount, 2)),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { narration.speak(String(localized: "colorFreePlayTitle")) }
        ) {
            ColorStampBoard(viewModel: viewModel)
                .sensoryFeedback(.impact, trigger: viewModel.pieceCount)
        }
    }
}

#Preview("Colour Free Play — warm") {
    NavigationStack {
        ColorFreePlayView()
            .environment(\.palette, .warm)
            .environment(NarrationService(profile: ProfileStore()))
    }
}
