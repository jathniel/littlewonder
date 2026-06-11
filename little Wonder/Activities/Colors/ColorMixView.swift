import SwiftUI

struct ColorMixView: View {
    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(\.dismiss) private var dismiss
    @Environment(ColorProgressStore.self) private var progress
    @Environment(NarrationService.self) private var narration
    @State private var viewModel = ColorMixViewModel()

    var body: some View {
        ActivityStage(
            kicker: "colorMixKicker",
            title: "colorMixTitle",
            prompt: "colorMixPrompt",
            progress: ProgressDots(count: viewModel.totalRounds, active: viewModel.completedRounds),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { narration.speak(String(localized: "colorMixPrompt")) }
        ) {
            VStack(spacing: Spacing.lg) {
                ColorMixGoal(viewModel: viewModel)
                ColorMixWell(viewModel: viewModel)
                ColorMixPots(viewModel: viewModel)
                ColorMixFooter(viewModel: viewModel)
            }
            .task {
                viewModel.onComplete = { [progress] in progress.recordMix() }
            }
            .overlay(alignment: .top) {
                if viewModel.celebrate {
                    CelebrationBadge(text: "colorMixCelebration")
                        .padding(.top, Spacing.md)
                }
            }
            .animation(pace.longAnimation, value: viewModel.celebrate)
            .sensoryFeedback(.impact, trigger: viewModel.result)
            .sensoryFeedback(.success, trigger: viewModel.celebrate)
            .onChange(of: viewModel.result) { _, result in
                // Name the blend in the well; the celebration line takes over on the last round.
                if let result, !viewModel.celebrate {
                    narration.speak(result.localizedName)
                }
            }
            .onChange(of: viewModel.celebrate) { _, celebrate in
                if celebrate {
                    narration.speak(String(localized: "colorMixCelebration"))
                }
            }
        }
    }
}

private struct ColorMixGoal: View {
    let viewModel: ColorMixViewModel

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("colorMixGoalKicker")
                    .font(FontStack.mono)
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)
                Text("colorMixGoalTitle \(Text(viewModel.target.nameKey))")
                    .font(.system(.title2, design: .serif))
                    .foregroundStyle(palette.ink)
            }
            Spacer()
            SwatchTarget(swatch: viewModel.target, size: 64, placed: viewModel.solvedRound)
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

/// The mixing well: shows the current result colour, or an empty cup until two
/// primaries are chosen.
private struct ColorMixWell: View {
    let viewModel: ColorMixViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        ZStack {
            Circle()
                .fill(palette.paperHi)
                .overlay { Circle().stroke(palette.line, style: StrokeStyle(lineWidth: 2, dash: [7, 7])) }

            if let result = viewModel.result {
                ColorBlob(swatch: result, size: 150)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Image(systemName: "drop")
                    .font(.system(size: 48, weight: .regular))
                    .foregroundStyle(palette.inkSoft)
            }
        }
        .frame(width: 180, height: 180)
        .animation(pace.baseAnimation, value: viewModel.result)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("colorMixWellA11y"))
        .accessibilityValue(viewModel.result.map { Text($0.nameKey) } ?? Text("colorMixWellEmptyA11y"))
    }
}

private struct ColorMixPots: View {
    let viewModel: ColorMixViewModel

    var body: some View {
        HStack(spacing: Spacing.lg) {
            ForEach(viewModel.pots) { pot in
                ColorMixPot(swatch: pot, viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ColorMixPot: View {
    let swatch: ColorSwatch
    let viewModel: ColorMixViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    private var selected: Bool { viewModel.isSelected(swatch) }

    var body: some View {
        Button {
            viewModel.tap(swatch)
        } label: {
            VStack(spacing: Spacing.sm) {
                ColorBlob(swatch: swatch, size: 88)
                    .scaleEffect(selected ? 1.08 : 1)
                    .overlay {
                        if selected {
                            Circle().stroke(palette.ink, lineWidth: 3)
                        }
                    }
                Text(swatch.nameKey)
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
            }
            .animation(pace.fastAnimation, value: selected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(swatch.nameKey)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
}

private struct ColorMixFooter: View {
    let viewModel: ColorMixViewModel

    var body: some View {
        Group {
            if viewModel.solvedRound && !viewModel.isLastRound {
                PillButton(title: "colorMixNext", kind: .primary, size: .md) {
                    viewModel.advanceRound()
                }
            } else {
                Color.clear.frame(height: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Colour Mix — warm") {
    NavigationStack {
        ColorMixView()
            .environment(\.palette, .warm)
            .environment(ColorProgressStore())
            .environment(NarrationService(profile: ProfileStore()))
    }
}
