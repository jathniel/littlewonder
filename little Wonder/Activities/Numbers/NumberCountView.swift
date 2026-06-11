import SwiftUI

struct NumberCountView: View {
    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(\.dismiss) private var dismiss
    @Environment(NumberProgressStore.self) private var progress
    @Environment(NarrationService.self) private var narration
    @State private var viewModel = NumberCountViewModel()

    var body: some View {
        ActivityStage(
            kicker: "numberCountKicker",
            title: "numberCountTitle",
            prompt: "numberCountPrompt",
            progress: ProgressDots(count: viewModel.totalRounds, active: viewModel.completedRounds),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { narration.speak(String(localized: "numberCountPrompt")) }
        ) {
            VStack(spacing: Spacing.lg) {
                NumberCountTally(viewModel: viewModel)
                NumberCountField(viewModel: viewModel)
                NumberCountFooter(viewModel: viewModel)
            }
            .task {
                viewModel.onComplete = { [progress] in progress.recordCount() }
            }
            .overlay(alignment: .top) {
                if viewModel.celebrate {
                    CelebrationBadge(text: "numberCountCelebration")
                        .padding(.top, Spacing.md)
                }
            }
            .animation(pace.longAnimation, value: viewModel.celebrate)
            .sensoryFeedback(.impact, trigger: viewModel.countedCount)
            .sensoryFeedback(.success, trigger: viewModel.celebrate)
            .onChange(of: viewModel.celebrate) { _, celebrate in
                if celebrate {
                    narration.speak(String(localized: "numberCountCelebration"))
                }
            }
        }
    }
}

private struct NumberCountTally: View {
    let viewModel: NumberCountViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(viewModel.countedCount, format: .number)
                .font(.system(size: 96, weight: .regular, design: .serif))
                .foregroundStyle(palette.ink)
                .contentTransition(.numericText())
                .animation(pace.baseAnimation, value: viewModel.countedCount)
            Text("numberCountTallyHint \(viewModel.currentCount)")
                .font(FontStack.mono)
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)
        }
    }
}

private struct NumberCountField: View {
    let viewModel: NumberCountViewModel

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: Spacing.md)], spacing: Spacing.md) {
            ForEach(viewModel.items) { item in
                NumberCountDot(item: item, viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.default, value: viewModel.roundIndex)
    }
}

private struct NumberCountDot: View {
    let item: NumberCountViewModel.Item
    let viewModel: NumberCountViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(NarrationService.self) private var narration

    var body: some View {
        Button {
            let isNewCount = !item.counted
            viewModel.tap(item.id)
            // Count aloud; the celebration line takes over on the final dot.
            if isNewCount, !viewModel.celebrate {
                narration.speak(viewModel.countedCount.formatted(.number))
            }
        } label: {
            PrimitiveShape(kind: .circle, size: 84, fill: palette.sky)
                .opacity(item.counted ? 1 : 0.35)
                .overlay {
                    if item.counted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(palette.paperHi)
                    }
                }
                .scaleEffect(item.counted ? 1 : 0.92)
                .animation(pace.baseAnimation, value: item.counted)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("numberCountDotA11y"))
        .accessibilityValue(item.counted ? Text("numberCountedA11y") : Text("numberUncountedA11y"))
    }
}

private struct NumberCountFooter: View {
    let viewModel: NumberCountViewModel

    @Environment(\.palette) private var palette

    var body: some View {
        Group {
            if viewModel.roundComplete && !viewModel.isLastRound {
                PillButton(title: "numberCountNext", kind: .primary, size: .md) {
                    viewModel.advanceRound()
                }
            } else {
                Color.clear.frame(height: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
