import SwiftUI

struct NumberFreePlayView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NarrationService.self) private var narration
    @State private var viewModel = NumberStampViewModel()

    var body: some View {
        ActivityStage(
            kicker: "numberFreePlayKicker",
            title: "numberFreePlayTitle",
            prompt: nil,
            progress: ProgressDots(count: 3, active: min(viewModel.pieceCount, 2)),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { narration.speak(String(localized: "numberFreePlayTitle")) }
        ) {
            NumberStampBoard(viewModel: viewModel)
                .sensoryFeedback(.impact, trigger: viewModel.pieceCount)
        }
    }
}
