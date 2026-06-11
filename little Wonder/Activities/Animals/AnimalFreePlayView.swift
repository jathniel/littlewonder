import SwiftUI

struct AnimalFreePlayView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NarrationService.self) private var narration
    @State private var viewModel = AnimalStampViewModel()

    var body: some View {
        ActivityStage(
            kicker: "animalFreePlayKicker",
            title: "animalFreePlayTitle",
            prompt: nil,
            progress: ProgressDots(count: 3, active: min(viewModel.pieceCount, 2)),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { narration.speak(String(localized: "animalFreePlayTitle")) }
        ) {
            AnimalStampBoard(viewModel: viewModel)
                .sensoryFeedback(.impact, trigger: viewModel.pieceCount)
        }
    }
}

#Preview("Animal Free Play — warm") {
    NavigationStack {
        AnimalFreePlayView()
            .environment(\.palette, .warm)
            .environment(NarrationService(profile: ProfileStore()))
    }
}
