import SwiftUI

struct ShapeFreePlayView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ShapeBuildViewModel(mode: .freePlay)

    var body: some View {
        ActivityStage(
            kicker: "shapeFreePlayKicker",
            title: "shapeFreePlayTitle",
            prompt: nil,
            progress: AnyView(ProgressDots(count: 3, active: min(viewModel.pieceCount, 2))),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { /* TODO: AVSpeechSynthesizer */ }
        ) {
            ShapeBuildBoard(viewModel: viewModel, showsFooter: false)
        }
    }
}
