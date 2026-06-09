import SwiftUI

struct NumberOrderView: View {
    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(\.dismiss) private var dismiss
    @Environment(NumberProgressStore.self) private var progress
    @State private var viewModel = NumberOrderViewModel()

    var body: some View {
        ActivityStage(
            kicker: "numberOrderKicker",
            title: "numberOrderTitle",
            prompt: "numberOrderPrompt",
            progress: AnyView(ProgressDots(count: viewModel.total, active: viewModel.placedCount)),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { /* TODO: wire AVSpeechSynthesizer */ }
        ) {
            VStack(spacing: Spacing.xl) {
                NumberOrderSlots(viewModel: viewModel)
                NumberOrderTray(viewModel: viewModel)
            }
            .task {
                viewModel.onComplete = { [progress] in progress.recordOrder() }
            }
            .overlay(alignment: .top) {
                if viewModel.celebrate {
                    CelebrationBadge(text: "numberOrderCelebration")
                        .padding(.top, Spacing.md)
                }
            }
            .animation(pace.longAnimation, value: viewModel.celebrate)
        }
    }
}

private struct NumberOrderSlots: View {
    let viewModel: NumberOrderViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        HStack(spacing: Spacing.md) {
            ForEach(viewModel.sequence.enumerated(), id: \.offset) { index, value in
                slot(at: index, value: value)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func slot(at index: Int, value: Int) -> some View {
        let filled = viewModel.slots[index] != nil
        let isNext = viewModel.placedCount == index
        ZStack {
            if filled {
                NumeralTile(value: value, fill: palette[keyPath: color(for: value)], size: 96)
                    .transition(.scale.combined(with: .opacity))
            } else {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isNext ? palette.sage : palette.line,
                            style: StrokeStyle(lineWidth: isNext ? 3 : 2, dash: [7, 7]))
                    .frame(width: 96, height: 96)
                    .overlay {
                        Text(value, format: .number)
                            .font(.system(size: 30, weight: .regular, design: .serif))
                            .foregroundStyle(palette.line)
                    }
            }
        }
        .frame(width: 96, height: 96)
        .animation(pace.baseAnimation, value: filled)
    }

    private func color(for value: Int) -> KeyPath<Palette, Color> {
        let options = NumberOrderViewModel.paletteOptions
        return options[(value - 1) % options.count]
    }
}

private struct NumberOrderTray: View {
    let viewModel: NumberOrderViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Text("numberOrderTrayLabel")
                    .font(FontStack.mono)
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)
                Spacer()
            }

            HStack(spacing: Spacing.md) {
                ForEach(viewModel.tray) { number in
                    NumberOrderTrayTile(number: number, viewModel: viewModel)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(palette.sand, in: .rect(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(palette.line, lineWidth: 1)
        }
        .animation(pace.baseAnimation, value: viewModel.tray.count)
    }
}

private struct NumberOrderTrayTile: View {
    let number: NumberOrderViewModel.TrayNumber
    let viewModel: NumberOrderViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @State private var wiggle = false

    var body: some View {
        Button {
            let placed = viewModel.place(number.value)
            if !placed {
                withAnimation(pace.fastAnimation) { wiggle = true }
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(180))
                    withAnimation(pace.fastAnimation) { wiggle = false }
                }
            }
        } label: {
            NumeralTile(value: number.value, fill: palette[keyPath: number.color], size: 88)
                .rotationEffect(.degrees(wiggle ? -5 : 0))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("numberA11y \(number.value)"))
        .accessibilityAddTraits(.isButton)
    }
}
