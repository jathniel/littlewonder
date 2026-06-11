import SwiftUI

struct AnimalFindView: View {
    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(\.dismiss) private var dismiss
    @Environment(AnimalProgressStore.self) private var progress
    @Environment(NarrationService.self) private var narration
    @State private var viewModel = AnimalFindViewModel()

    var body: some View {
        ActivityStage(
            kicker: "animalFindKicker",
            title: "animalFindTitle",
            prompt: "animalFindPrompt",
            progress: ProgressDots(count: viewModel.totalRounds, active: viewModel.completedRounds),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { narration.speak(String(localized: "animalFindPrompt")) }
        ) {
            VStack(spacing: Spacing.lg) {
                AnimalFindBanner(viewModel: viewModel)
                AnimalFindField(viewModel: viewModel)
                AnimalFindFooter(viewModel: viewModel)
            }
            .task {
                viewModel.onComplete = { [progress] in progress.recordFind() }
            }
            .overlay(alignment: .top) {
                if viewModel.celebrate {
                    CelebrationBadge(text: "animalFindCelebration")
                        .padding(.top, Spacing.md)
                }
            }
            .animation(pace.longAnimation, value: viewModel.celebrate)
            .sensoryFeedback(.impact, trigger: viewModel.foundCount)
            .sensoryFeedback(.success, trigger: viewModel.celebrate)
            .onChange(of: viewModel.roundIndex) { _, _ in
                narration.speak(viewModel.target.localizedName)
            }
            .onChange(of: viewModel.celebrate) { _, celebrate in
                if celebrate {
                    narration.speak(String(localized: "animalFindCelebration"))
                }
            }
        }
    }
}

private struct AnimalFindBanner: View {
    let viewModel: AnimalFindViewModel

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: Spacing.md) {
            AnimalGlyph(animal: viewModel.target, size: 56)
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("animalFindBannerKicker")
                    .font(FontStack.mono)
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)
                Text("animalFindBannerTitle \(Text(viewModel.target.nameKey))")
                    .font(.system(.title2, design: .serif))
                    .foregroundStyle(palette.ink)
            }
            Spacer()
            Text("\(viewModel.foundCount) / \(viewModel.matchTotal)")
                .font(.system(.title3, design: .monospaced))
                .foregroundStyle(palette.inkSoft)
                .contentTransition(.numericText())
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .background(palette.sand, in: .rect(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(palette.line, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct AnimalFindField: View {
    let viewModel: AnimalFindViewModel

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: Spacing.md)], spacing: Spacing.md) {
            ForEach(viewModel.items) { item in
                AnimalFindChip(item: item, viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.default, value: viewModel.roundIndex)
    }
}

private struct AnimalFindChip: View {
    let item: AnimalFindViewModel.Item
    let viewModel: AnimalFindViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(NarrationService.self) private var narration

    var body: some View {
        Button {
            let isNewFind = item.animal == viewModel.target && !item.found
            viewModel.tap(item.id)
            // The celebration line takes over when this was the final find.
            if isNewFind, !viewModel.celebrate {
                narration.speak(item.animal.localizedName)
            }
        } label: {
            AnimalToken(animal: item.animal, size: 84)
                .opacity(item.found ? 0.4 : 1)
                .overlay {
                    if item.found {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(palette.sage)
                    }
                }
                .scaleEffect(item.found ? 0.92 : 1)
                .animation(pace.baseAnimation, value: item.found)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.animal.nameKey)
        .accessibilityValue(item.found ? Text("animalFoundA11y") : Text(""))
    }
}

private struct AnimalFindFooter: View {
    let viewModel: AnimalFindViewModel

    var body: some View {
        Group {
            if viewModel.roundComplete && !viewModel.isLastRound {
                PillButton(title: "animalFindNext", kind: .primary, size: .md) {
                    viewModel.advanceRound()
                }
            } else {
                Color.clear.frame(height: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Animal Find — warm") {
    NavigationStack {
        AnimalFindView()
            .environment(\.palette, .warm)
            .environment(AnimalProgressStore())
            .environment(NarrationService(profile: ProfileStore()))
    }
}
