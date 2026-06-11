import SwiftUI

struct ColorMatchView: View {
    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(\.dismiss) private var dismiss
    @Environment(ColorProgressStore.self) private var progress
    @Environment(NarrationService.self) private var narration
    @State private var viewModel = ColorMatchViewModel()

    var body: some View {
        ActivityStage(
            kicker: "colorMatchKicker",
            title: "colorMatchTitle",
            prompt: "colorMatchPrompt",
            progress: ProgressDots(count: viewModel.total, active: viewModel.placedCount),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { narration.speak(String(localized: "colorMatchPrompt")) }
        ) {
            VStack(spacing: Spacing.md + 4) {
                ColorMatchCanvas(viewModel: viewModel)
                ColorMatchTray(viewModel: viewModel)
            }
            .task {
                viewModel.onComplete = { [progress] in progress.recordMatch() }
            }
            .overlay(alignment: .top) {
                if viewModel.celebrate {
                    CelebrationBadge(text: "colorMatchCelebration")
                        .padding(.top, Spacing.md)
                }
            }
            .animation(pace.longAnimation, value: viewModel.celebrate)
            .sensoryFeedback(.impact, trigger: viewModel.placedCount)
            .sensoryFeedback(.success, trigger: viewModel.celebrate)
            .onChange(of: viewModel.celebrate) { _, celebrate in
                if celebrate {
                    narration.speak(String(localized: "colorMatchCelebration"))
                }
            }
        }
    }
}

private struct ColorMatchCanvas: View {
    let viewModel: ColorMatchViewModel

    @Environment(\.pace) private var pace

    var body: some View {
        let logical = ColorMatchViewModel.canvasSize
        GeometryReader { proxy in
            let scale = min(proxy.size.width / logical.width, proxy.size.height / logical.height)
            ZStack(alignment: .topLeading) {
                ForEach(viewModel.pieces) { piece in
                    ColorMatchDropFrame(swatch: piece.swatch, placed: piece.placed)
                        .position(piece.target)
                }
                ForEach(viewModel.pieces) { piece in
                    ColorMatchPiece(piece: piece, viewModel: viewModel)
                        .position(piece.position)
                }
            }
            .frame(width: logical.width, height: logical.height)
            .coordinateSpace(name: "colorMatchStage")
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: logical.width * scale, height: logical.height * scale, alignment: .topLeading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(pace.baseAnimation, value: viewModel.placedCount)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ColorMatchPiece: View {
    let piece: ColorMatchViewModel.Piece
    let viewModel: ColorMatchViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(NarrationService.self) private var narration
    @State private var isDragging = false

    var body: some View {
        SwatchChip(swatch: piece.swatch, size: ColorMatchViewModel.pieceSize)
            .scaleEffect(isDragging ? 1.05 : 1)
            .shadow(color: palette.ink.opacity(isDragging ? 0.18 : 0.06),
                    radius: isDragging ? 18 : 6,
                    y: isDragging ? 10 : 2)
            .gesture(dragGesture)
            .animation(pace.baseAnimation, value: piece.position)
            .animation(pace.fastAnimation, value: isDragging)
            .accessibilityLabel(piece.swatch.nameKey)
            .accessibilityAddTraits(.isButton)
            .accessibilityValue(piece.placed ? Text("colorMatchedA11y") : Text("colorPieceDraggingA11y"))
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("colorMatchStage"))
            .onChanged { value in
                guard !piece.placed else { return }
                isDragging = true
                viewModel.updateDrag(piece.id, to: value.location)
            }
            .onEnded { _ in
                isDragging = false
                // The celebration line takes over when this was the final piece.
                if viewModel.endDrag(piece.id), !viewModel.celebrate {
                    narration.speak(piece.swatch.localizedName)
                }
            }
    }
}

/// The drop target: an outlined, faintly tinted frame in the matching colour.
private struct ColorMatchDropFrame: View {
    let swatch: ColorSwatch
    let placed: Bool

    @Environment(\.pace) private var pace

    var body: some View {
        SwatchTarget(swatch: swatch, size: ColorMatchViewModel.pieceSize, placed: placed)
            .animation(pace.fastAnimation, value: placed)
            .accessibilityLabel(swatch.nameKey)
            .accessibilityValue(Text("colorMatchTargetA11y"))
    }
}

private struct ColorMatchTray: View {
    let viewModel: ColorMatchViewModel

    @Environment(\.palette) private var palette

    var body: some View {
        HStack {
            Text("colorMatchTrayLabel")
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

#Preview("Colour Match — warm") {
    NavigationStack {
        ColorMatchView()
            .environment(\.palette, .warm)
            .environment(ColorProgressStore())
            .environment(NarrationService(profile: ProfileStore()))
    }
}
