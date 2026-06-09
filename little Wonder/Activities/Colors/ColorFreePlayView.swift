import SwiftUI

struct ColorFreePlayView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ColorStampViewModel()

    var body: some View {
        ActivityStage(
            kicker: "colorFreePlayKicker",
            title: "colorFreePlayTitle",
            prompt: nil,
            progress: AnyView(ProgressDots(count: 3, active: min(viewModel.pieceCount, 2))),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { /* TODO: wire AVSpeechSynthesizer (Gate B) */ }
        ) {
            ColorStampBoard(viewModel: viewModel)
        }
    }
}

#Preview("Colour Free Play — warm") {
    NavigationStack {
        ColorFreePlayView()
            .environment(\.palette, .warm)
    }
}
