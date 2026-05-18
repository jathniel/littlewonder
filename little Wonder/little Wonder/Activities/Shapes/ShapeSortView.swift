import SwiftUI

struct ShapeSortView: View {
    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ShapeSortViewModel()

    var body: some View {
        ActivityStage(
            kicker: "shapeSortKicker",
            title: "shapeSortTitle",
            prompt: "shapeSortPrompt",
            progress: AnyView(ProgressDots(count: 3, active: max(0, 3 - viewModel.remaining))),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { /* TODO: AVSpeechSynthesizer */ }
        ) {
            VStack(spacing: Spacing.lg) {
                ShapeSortBins(bins: viewModel.bins)
                ShapeSortTray(viewModel: viewModel)
            }
        }
    }
}

private struct ShapeSortBins: View {
    let bins: [ShapeSortViewModel.Bin]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 28), count: 3), spacing: 28) {
            ForEach(bins) { bin in
                ShapeSortBinView(bin: bin)
            }
        }
    }
}

private struct ShapeSortBinView: View {
    let bin: ShapeSortViewModel.Bin

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        let accent = palette[keyPath: bin.accent]
        ZStack(alignment: .bottomLeading) {
            accent.opacity(0.10)

            // Top highlight: a faint white slice.
            VStack {
                Rectangle().fill(.white.opacity(0.4)).frame(height: 1)
                Spacer()
            }

            // Ghost outline upper-right.
            PrimitiveShape(kind: bin.kind, size: 110, stroke: accent, strokeWidth: 2)
                .opacity(0.18)
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            // Placed pieces.
            GeometryReader { proxy in
                let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2 + 30)
                ZStack {
                    ForEach(bin.placed) { piece in
                        PrimitiveShape(kind: piece.kind, size: 60, fill: palette[keyPath: piece.color])
                            .position(x: center.x + piece.offset.width, y: center.y + piece.offset.height)
                            .transition(.scale(scale: 0.85).combined(with: .opacity))
                    }
                }
                .animation(pace.longAnimation, value: bin.placed.count)
            }

            // Label tab.
            HStack(spacing: Spacing.sm) {
                Text(bin.labelKey)
                    .font(.system(.title3, design: .serif).italic())
                    .foregroundStyle(palette.ink)
                Text("shapeSortBinInsideCount \(bin.placed.count)")
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
    }
}

private struct ShapeSortTray: View {
    let viewModel: ShapeSortViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @State private var nudgePhase: CGFloat = -4

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Text("shapeSortTrayLabel \(viewModel.remaining)")
                    .font(FontStack.mono)
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)
                Spacer()
            }

            HStack(spacing: Spacing.md) {
                ForEach(viewModel.tray.enumerated(), id: \.element.id) { index, piece in
                    ShapeSortTrayPiece(piece: piece, isLead: index == 0, viewModel: viewModel, nudgePhase: index == 0 ? nudgePhase : 0)
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

private struct ShapeSortTrayPiece: View {
    let piece: ShapeSortViewModel.TrayPiece
    let isLead: Bool
    let viewModel: ShapeSortViewModel
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
            PrimitiveShape(kind: piece.kind, size: 70, fill: palette[keyPath: piece.color])
                .scaleEffect(isLead ? 1.06 : 1)
                .offset(y: isLead ? -4 : 0)
                .offset(dragOffset)
                .gesture(dragGesture)
                .animation(pace.baseAnimation, value: dragOffset)
        }
        .accessibilityLabel(Text("shapeA11y \(piece.kind.rawValue)"))
        .accessibilityAddTraits(.isButton)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                dragOffset = value.translation
            }
            .onEnded { value in
                isDragging = false
                // Treat any upward fling (>= 90pt) as a "drop into bin" gesture for v1.
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
