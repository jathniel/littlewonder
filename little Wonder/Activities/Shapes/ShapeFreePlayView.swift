import SwiftUI

struct ShapeFreePlayView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NarrationService.self) private var narration
    @State private var viewModel = ShapeBuildViewModel(mode: .freePlay)

    var body: some View {
        ActivityStage(
            kicker: "shapeFreePlayKicker",
            title: "shapeFreePlayTitle",
            prompt: nil,
            progress: ProgressDots(count: 3, active: min(viewModel.pieceCount, 2)),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { narration.speak(String(localized: "shapeFreePlayTitle")) }
        ) {
            ShapeBuildBoard(viewModel: viewModel, showsFooter: false)
                .sensoryFeedback(.impact, trigger: viewModel.pieceCount)
        }
    }
}
