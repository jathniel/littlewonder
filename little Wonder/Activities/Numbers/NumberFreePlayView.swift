import SwiftUI

struct NumberFreePlayView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = NumberStampViewModel()

    var body: some View {
        ActivityStage(
            kicker: "numberFreePlayKicker",
            title: "numberFreePlayTitle",
            prompt: nil,
            progress: AnyView(ProgressDots(count: 3, active: min(viewModel.pieceCount, 2))),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { /* TODO: wire AVSpeechSynthesizer */ }
        ) {
            NumberStampBoard(viewModel: viewModel)
        }
    }
}
