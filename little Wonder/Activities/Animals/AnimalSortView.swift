import SwiftUI

struct AnimalSortView: View {
    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(\.dismiss) private var dismiss
    @Environment(AnimalProgressStore.self) private var progress
    @Environment(NarrationService.self) private var narration
    @State private var viewModel = AnimalSortViewModel()

    var body: some View {
        ActivityStage(
            kicker: "animalSortKicker",
            title: "animalSortTitle",
            prompt: "animalSortPrompt",
            progress: ProgressDots(count: viewModel.total, active: viewModel.total - viewModel.remaining),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { narration.speak(String(localized: "animalSortPrompt")) }
        ) {
            VStack(spacing: Spacing.lg) {
                AnimalSortBins(bins: viewModel.bins)
                AnimalSortTray(viewModel: viewModel)
            }
            .task {
                viewModel.onComplete = { [progress] in progress.recordSort() }
            }
            .overlay(alignment: .top) {
                if viewModel.celebrate {
                    CelebrationBadge(text: "animalSortCelebration")
                        .padding(.top, Spacing.md)
                }
            }
            .animation(pace.longAnimation, value: viewModel.celebrate)
            .sensoryFeedback(.impact, trigger: viewModel.remaining)
            .sensoryFeedback(.success, trigger: viewModel.celebrate)
            .onChange(of: viewModel.celebrate) { _, celebrate in
                if celebrate {
                    narration.speak(String(localized: "animalSortCelebration"))
                }
            }
        }
    }
}

private struct AnimalSortBins: View {
    let bins: [AnimalSortViewModel.Bin]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 28), count: bins.count), spacing: 28) {
            ForEach(bins) { bin in
                AnimalSortBinView(bin: bin)
            }
        }
    }
}

private struct AnimalSortBinView: View {
    let bin: AnimalSortViewModel.Bin

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        let accent = palette[keyPath: bin.habitat.accent]
        ZStack(alignment: .bottomLeading) {
            accent.opacity(0.10)

            // Top highlight: a faint white slice.
            VStack {
                Rectangle().fill(.white.opacity(0.4)).frame(height: 1)
                Spacer()
            }

            // Ghost habitat icon, upper-right.
            Image(systemName: bin.habitat.symbol)
                .font(.system(size: 88))
                .foregroundStyle(accent.opacity(0.18))
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            // Placed animals.
            GeometryReader { proxy in
                let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2 + 30)
                ZStack {
                    ForEach(bin.placed) { piece in
                        AnimalGlyph(animal: piece.animal, size: 60)
                            .position(x: center.x + piece.offset.width, y: center.y + piece.offset.height)
                            .transition(.scale(scale: 0.85).combined(with: .opacity))
                    }
                }
                .animation(pace.longAnimation, value: bin.placed.count)
            }

            // Label tab.
            HStack(spacing: Spacing.sm) {
                Text(bin.habitat.nameKey)
                    .font(.system(.title3, design: .serif).italic())
                    .foregroundStyle(palette.ink)
                Text("animalSortBinInsideCount \(bin.placed.count)")
                    .font(FontStack.mono)
                    .foregroundStyle(palette.inkSoft)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(palette.paperHi, in: .capsule)
            .overlay { Capsule().stroke(palette.line, lineWidth: 1) }
            .padding(Spacing.md)
        }
        .frame(height: 280)
        .clipShape(.rect(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(accent.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(bin.habitat.nameKey)
        .accessibilityValue(Text("animalSortBinInsideCount \(bin.placed.count)"))
    }
}

private struct AnimalSortTray: View {
    let viewModel: AnimalSortViewModel

    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var nudgePhase: CGFloat = -4

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Text("animalSortTrayLabel \(viewModel.remaining)")
                    .font(FontStack.mono)
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)
                Spacer()
            }

            HStack(spacing: Spacing.md) {
                ForEach(viewModel.tray.enumerated(), id: \.element.id) { index, piece in
                    AnimalSortTrayPiece(piece: piece, isLead: index == 0, viewModel: viewModel, nudgePhase: index == 0 ? nudgePhase : 0)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(palette.sand, in: .rect(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(palette.line, lineWidth: 1)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                nudgePhase = -16
            }
        }
    }
}

private struct AnimalSortTrayPiece: View {
    let piece: AnimalSortViewModel.TrayPiece
    let isLead: Bool
    let viewModel: AnimalSortViewModel
    let nudgePhase: CGFloat

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(NarrationService.self) private var narration
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .top) {
            if isLead {
                Image(systemName: "arrow.up")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(palette.inkSoft)
                    .offset(y: nudgePhase - 20)
            }
            AnimalGlyph(animal: piece.animal, size: 76)
                .scaleEffect(isLead ? 1.06 : 1)
                .offset(y: isLead ? -4 : 0)
                .offset(dragOffset)
                .gesture(dragGesture)
                .animation(pace.baseAnimation, value: dragOffset)
        }
        .accessibilityLabel(piece.animal.nameKey)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(Text("animalSortPieceHintA11y"))
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                // Treat any upward fling (>= 90pt) as a "drop into bin" gesture.
                if value.translation.height < -90 {
                    var didPlace = false
                    withAnimation(pace.baseAnimation) {
                        didPlace = viewModel.place(pieceID: piece.id)
                    }
                    // The celebration line takes over when this emptied the tray.
                    if didPlace, !viewModel.celebrate {
                        narration.speak(piece.animal.localizedName)
                    }
                }
                withAnimation(pace.baseAnimation) {
                    dragOffset = .zero
                }
            }
    }
}

#Preview("Animal Sort — warm") {
    NavigationStack {
        AnimalSortView()
            .environment(\.palette, .warm)
            .environment(AnimalProgressStore())
            .environment(NarrationService(profile: ProfileStore()))
    }
}
