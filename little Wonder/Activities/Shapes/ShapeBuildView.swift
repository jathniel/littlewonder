import SwiftUI

struct ShapeBuildView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ShapeBuildViewModel(mode: .build)

    var body: some View {
        ActivityStage(
            kicker: "shapeBuildKicker",
            title: "shapeBuildTitle",
            prompt: "shapeBuildPrompt",
            progress: AnyView(ProgressDots(count: 3, active: min(viewModel.pieceCount, 2))),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { /* TODO: AVSpeechSynthesizer */ }
        ) {
            ShapeBuildBoard(viewModel: viewModel, showsFooter: true)
        }
    }
}
