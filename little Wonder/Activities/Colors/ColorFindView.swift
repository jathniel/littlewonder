import SwiftUI

struct ColorFindView: View {
    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(\.dismiss) private var dismiss
    @Environment(ColorProgressStore.self) private var progress
    @State private var viewModel = ColorFindViewModel()

    var body: some View {
        ActivityStage(
            kicker: "colorFindKicker",
            title: "colorFindTitle",
            prompt: "colorFindPrompt",
            progress: AnyView(ProgressDots(count: viewModel.totalRounds, active: viewModel.completedRounds)),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { /* TODO: wire AVSpeechSynthesizer (Gate B) */ }
        ) {
            VStack(spacing: Spacing.lg) {
                ColorFindBanner(viewModel: viewModel)
                ColorFindField(viewModel: viewModel)
                ColorFindFooter(viewModel: viewModel)
            }
            .task {
                viewModel.onComplete = { [progress] in progress.recordFind() }
            }
            .overlay(alignment: .top) {
                if viewModel.celebrate {
                    CelebrationBadge(text: "colorFindCelebration")
                        .padding(.top, Spacing.md)
                }
            }
            .animation(pace.longAnimation, value: viewModel.celebrate)
        }
    }
}

private struct ColorFindBanner: View {
    let viewModel: ColorFindViewModel

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: Spacing.md) {
            ColorBlob(swatch: viewModel.target, size: 56)
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("colorFindBannerKicker")
                    .font(FontStack.mono)
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)
                Text("colorFindBannerTitle \(Text(viewModel.target.nameKey))")
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

private struct ColorFindField: View {
    let viewModel: ColorFindViewModel

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: Spacing.md)], spacing: Spacing.md) {
            ForEach(viewModel.items) { item in
                ColorFindChip(item: item, viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.default, value: viewModel.roundIndex)
    }
}

private struct ColorFindChip: View {
    let item: ColorFindViewModel.Item
    let viewModel: ColorFindViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        Button {
            viewModel.tap(item.id)
        } label: {
            SwatchChip(swatch: item.swatch, size: 84)
                .opacity(item.found ? 0.4 : 1)
                .overlay {
                    if item.found {
                        Image(systemName: "checkmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .scaleEffect(item.found ? 0.92 : 1)
                .animation(pace.baseAnimation, value: item.found)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.swatch.nameKey)
        .accessibilityValue(item.found ? Text("colorFoundA11y") : Text(""))
    }
}

private struct ColorFindFooter: View {
    let viewModel: ColorFindViewModel

    var body: some View {
        Group {
            if viewModel.roundComplete && !viewModel.isLastRound {
                PillButton(title: "colorFindNext", kind: .primary, size: .md) {
                    viewModel.advanceRound()
                }
            } else {
                Color.clear.frame(height: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Colour Find — warm") {
    NavigationStack {
        ColorFindView()
            .environment(\.palette, .warm)
            .environment(ColorProgressStore())
    }
}
