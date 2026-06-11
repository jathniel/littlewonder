import SwiftUI

struct ShapeBuildView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NarrationService.self) private var narration
    @State private var viewModel = ShapeBuildViewModel(mode: .build)

    var body: some View {
        ActivityStage(
            kicker: "shapeBuildKicker",
            title: "shapeBuildTitle",
            prompt: "shapeBuildPrompt",
            progress: ProgressDots(count: 3, active: min(viewModel.pieceCount, 2)),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { narration.speak(String(localized: "shapeBuildPrompt")) }
        ) {
            ShapeBuildBoard(viewModel: viewModel, showsFooter: true)
                .sensoryFeedback(.impact, trigger: viewModel.pieceCount)
        }
    }
}
