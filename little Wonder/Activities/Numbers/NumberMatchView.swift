import SwiftUI

struct NumberMatchView: View {
    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(\.dismiss) private var dismiss
    @Environment(NumberProgressStore.self) private var progress
    @State private var viewModel = NumberMatchViewModel()

    var body: some View {
        ActivityStage(
            kicker: "numberMatchKicker",
            title: "numberMatchTitle",
            prompt: "numberMatchPrompt",
            progress: AnyView(ProgressDots(count: viewModel.total, active: viewModel.placedCount)),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { /* TODO: wire AVSpeechSynthesizer */ }
        ) {
            VStack(spacing: Spacing.md + 4) {
                NumberMatchCanvas(viewModel: viewModel)
                NumberMatchTray(viewModel: viewModel)
            }
            .task {
                viewModel.onComplete = { [progress] in progress.recordMatch() }
            }
            .overlay(alignment: .top) {
                if viewModel.celebrate {
                    CelebrationBadge(text: "numberMatchCelebration")
                        .padding(.top, Spacing.md)
                }
            }
            .animation(pace.longAnimation, value: viewModel.celebrate)
        }
    }
}

private struct NumberMatchCanvas: View {
    let viewModel: NumberMatchViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        let logical = NumberMatchViewModel.canvasSize
        GeometryReader { proxy in
            let scale = min(proxy.size.width / logical.width, proxy.size.height / logical.height)
            ZStack(alignment: .topLeading) {
                ForEach(viewModel.pieces) { piece in
                    DotCard(count: piece.value, color: palette[keyPath: piece.color], placed: piece.placed)
                        .position(piece.target)
                }
                ForEach(viewModel.pieces) { piece in
                    NumberMatchPiece(piece: piece, viewModel: viewModel)
                        .position(piece.position)
                }
            }
            .frame(width: logical.width, height: logical.height)
            .coordinateSpace(name: "numberMatchStage")
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: logical.width * scale, height: logical.height * scale, alignment: .topLeading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(pace.baseAnimation, value: viewModel.placedCount)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct NumberMatchPiece: View {
    let piece: NumberMatchViewModel.Piece
    let viewModel: NumberMatchViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @State private var isDragging = false

    var body: some View {
        NumeralTile(value: piece.value, fill: palette[keyPath: piece.color], size: NumberMatchViewModel.pieceSize)
            .scaleEffect(isDragging ? 1.05 : 1)
            .shadow(color: palette.ink.opacity(isDragging ? 0.18 : 0.06),
                    radius: isDragging ? 18 : 6,
                    y: isDragging ? 10 : 2)
            .gesture(dragGesture)
            .animation(pace.baseAnimation, value: piece.position)
            .animation(pace.fastAnimation, value: isDragging)
            .accessibilityLabel(Text("numberA11y \(piece.value)"))
            .accessibilityAddTraits(.isButton)
            .accessibilityValue(piece.placed ? Text("numberMatchedA11y") : Text("numberPieceDraggingA11y"))
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("numberMatchStage"))
            .onChanged { value in
                guard !piece.placed else { return }
                isDragging = true
                viewModel.updateDrag(piece.id, to: value.location)
            }
            .onEnded { _ in
                isDragging = false
                _ = viewModel.endDrag(piece.id)
            }
    }
}

/// The drop target: a dashed card showing `count` dots.
private struct DotCard: View {
    let count: Int
    let color: Color
    let placed: Bool

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        DotCluster(count: count, color: color, dotSize: 30)
            .frame(width: NumberMatchViewModel.pieceSize, height: NumberMatchViewModel.pieceSize)
            .background(palette.paperHi.opacity(placed ? 0 : 1), in: .rect(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(palette.line, style: StrokeStyle(lineWidth: 2.5, dash: [8, 8]))
                    .opacity(placed ? 0 : 1)
            }
            .animation(pace.fastAnimation, value: placed)
            .accessibilityHidden(true)
    }
}

private struct NumberMatchTray: View {
    let viewModel: NumberMatchViewModel

    @Environment(\.palette) private var palette

    var body: some View {
        HStack {
            Text("numberMatchTrayLabel")
                .font(FontStack.mono)
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)
            Spacer()
            Text("\(viewModel.placedCount) / \(viewModel.total)")
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(palette.inkSoft)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .frame(maxWidth: .infinity)
        .background(palette.sand, in: .rect(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(palette.line, lineWidth: 1)
        }
    }
}

#Preview("Number Match — warm") {
    NavigationStack {
        NumberMatchView()
            .environment(\.palette, .warm)
            .environment(NumberProgressStore())
    }
}
