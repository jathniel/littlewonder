import SwiftUI

struct ColorSortView: View {
    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(\.dismiss) private var dismiss
    @Environment(ColorProgressStore.self) private var progress
    @State private var viewModel = ColorSortViewModel()

    var body: some View {
        ActivityStage(
            kicker: "colorSortKicker",
            title: "colorSortTitle",
            prompt: "colorSortPrompt",
            progress: AnyView(ProgressDots(count: viewModel.total, active: viewModel.total - viewModel.remaining)),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { /* TODO: wire AVSpeechSynthesizer (Gate B) */ }
        ) {
            VStack(spacing: Spacing.lg) {
                ColorSortBins(bins: viewModel.bins)
                ColorSortTray(viewModel: viewModel)
            }
            .task {
                viewModel.onComplete = { [progress] in progress.recordSort() }
            }
            .overlay(alignment: .top) {
                if viewModel.celebrate {
                    CelebrationBadge(text: "colorSortCelebration")
                        .padding(.top, Spacing.md)
                }
            }
            .animation(pace.longAnimation, value: viewModel.celebrate)
        }
    }
}

private struct ColorSortBins: View {
    let bins: [ColorSortViewModel.Bin]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 28), count: bins.count), spacing: 28) {
            ForEach(bins) { bin in
                ColorSortBinView(bin: bin)
            }
        }
    }
}

private struct ColorSortBinView: View {
    let bin: ColorSortViewModel.Bin

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        let accent = palette[keyPath: bin.swatch.fill]
        ZStack(alignment: .bottomLeading) {
            accent.opacity(0.10)

            // Top highlight: a faint white slice.
            VStack {
                Rectangle().fill(.white.opacity(0.4)).frame(height: 1)
                Spacer()
            }

            // Ghost colour blob, upper-right.
            ColorBlob(swatch: bin.swatch, size: 110)
                .opacity(0.18)
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            // Placed pieces.
            GeometryReader { proxy in
                let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2 + 30)
                ZStack {
                    ForEach(bin.placed) { piece in
                        ColorBlob(swatch: piece.swatch, size: 60)
                            .position(x: center.x + piece.offset.width, y: center.y + piece.offset.height)
                            .transition(.scale(scale: 0.85).combined(with: .opacity))
                    }
                }
                .animation(pace.longAnimation, value: bin.placed.count)
            }

            // Label tab.
            HStack(spacing: Spacing.sm) {
                Text(bin.swatch.nameKey)
                    .font(.system(.title3, design: .serif).italic())
                    .foregroundStyle(palette.ink)
                Text("colorSortBinInsideCount \(bin.placed.count)")
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
        .accessibilityLabel(bin.swatch.nameKey)
        .accessibilityValue(Text("colorSortBinInsideCount \(bin.placed.count)"))
    }
}

private struct ColorSortTray: View {
    let viewModel: ColorSortViewModel

    @Environment(\.palette) private var palette
    @State private var nudgePhase: CGFloat = -4

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Text("colorSortTrayLabel \(viewModel.remaining)")
                    .font(FontStack.mono)
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)
                Spacer()
            }

            HStack(spacing: Spacing.md) {
                ForEach(viewModel.tray.enumerated(), id: \.element.id) { index, piece in
                    ColorSortTrayPiece(piece: piece, isLead: index == 0, viewModel: viewModel, nudgePhase: index == 0 ? nudgePhase : 0)
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
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                nudgePhase = -16
            }
        }
    }
}

private struct ColorSortTrayPiece: View {
    let piece: ColorSortViewModel.TrayPiece
    let isLead: Bool
    let viewModel: ColorSortViewModel
    let nudgePhase: CGFloat

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    var body: some View {
        ZStack(alignment: .top) {
            if isLead {
                Image(systemName: "arrow.up")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(palette.inkSoft)
                    .offset(y: nudgePhase - 20)
            }
            ColorBlob(swatch: piece.swatch, size: 70)
                .scaleEffect(isLead ? 1.06 : 1)
                .offset(y: isLead ? -4 : 0)
                .offset(dragOffset)
                .gesture(dragGesture)
                .animation(pace.baseAnimation, value: dragOffset)
        }
        .accessibilityLabel(piece.swatch.nameKey)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(Text("colorSortPieceHintA11y"))
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                dragOffset = value.translation
            }
            .onEnded { value in
                isDragging = false
                // Treat any upward fling (>= 90pt) as a "drop into bin" gesture.
                if value.translation.height < -90 {
                    withAnimation(pace.baseAnimation) {
                        _ = viewModel.place(pieceID: piece.id)
                    }
                }
                withAnimation(pace.baseAnimation) {
                    dragOffset = .zero
                }
            }
    }
}

#Preview("Colour Sort — warm") {
    NavigationStack {
        ColorSortView()
            .environment(\.palette, .warm)
            .environment(ColorProgressStore())
    }
}
