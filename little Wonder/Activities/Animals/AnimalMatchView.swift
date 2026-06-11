import SwiftUI

struct AnimalMatchView: View {
    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(\.dismiss) private var dismiss
    @Environment(AnimalProgressStore.self) private var progress
    @Environment(NarrationService.self) private var narration
    @State private var viewModel = AnimalMatchViewModel()

    var body: some View {
        ActivityStage(
            kicker: "animalMatchKicker",
            title: "animalMatchTitle",
            prompt: "animalMatchPrompt",
            progress: ProgressDots(count: viewModel.total, active: viewModel.placedCount),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { narration.speak(String(localized: "animalMatchPrompt")) }
        ) {
            VStack(spacing: Spacing.md + 4) {
                AnimalMatchCanvas(viewModel: viewModel)
                AnimalMatchTray(viewModel: viewModel)
            }
            .task {
                viewModel.onComplete = { [progress] in progress.recordMatch() }
            }
            .overlay(alignment: .top) {
                if viewModel.celebrate {
                    CelebrationBadge(text: "animalMatchCelebration")
                        .padding(.top, Spacing.md)
                }
            }
            .animation(pace.longAnimation, value: viewModel.celebrate)
            .sensoryFeedback(.impact, trigger: viewModel.placedCount)
            .sensoryFeedback(.success, trigger: viewModel.celebrate)
            .onChange(of: viewModel.celebrate) { _, celebrate in
                if celebrate {
                    narration.speak(String(localized: "animalMatchCelebration"))
                }
            }
        }
    }
}

private struct AnimalMatchCanvas: View {
    let viewModel: AnimalMatchViewModel

    @Environment(\.pace) private var pace

    var body: some View {
        let logical = AnimalMatchViewModel.canvasSize
        GeometryReader { proxy in
            let scale = min(proxy.size.width / logical.width, proxy.size.height / logical.height)
            ZStack(alignment: .topLeading) {
                ForEach(viewModel.pieces) { piece in
                    AnimalMatchDropFrame(animal: piece.animal, placed: piece.placed)
                        .position(piece.target)
                }
                ForEach(viewModel.pieces) { piece in
                    AnimalMatchPiece(piece: piece, viewModel: viewModel)
                        .position(piece.position)
                }
            }
            .frame(width: logical.width, height: logical.height)
            .coordinateSpace(name: "animalMatchStage")
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: logical.width * scale, height: logical.height * scale, alignment: .topLeading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(pace.baseAnimation, value: viewModel.placedCount)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct AnimalMatchPiece: View {
    let piece: AnimalMatchViewModel.Piece
    let viewModel: AnimalMatchViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(NarrationService.self) private var narration
    @State private var isDragging = false

    var body: some View {
        AnimalToken(animal: piece.animal, size: AnimalMatchViewModel.pieceSize)
            .scaleEffect(isDragging ? 1.05 : 1)
            .shadow(color: palette.ink.opacity(isDragging ? 0.18 : 0.06),
                    radius: isDragging ? 18 : 6,
                    y: isDragging ? 10 : 2)
            .gesture(dragGesture)
            .animation(pace.baseAnimation, value: piece.position)
            .animation(pace.fastAnimation, value: isDragging)
            .accessibilityLabel(piece.animal.nameKey)
            .accessibilityAddTraits(.isButton)
            .accessibilityValue(piece.placed ? Text("animalMatchedA11y") : Text("animalPieceDraggingA11y"))
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("animalMatchStage"))
            .onChanged { value in
                guard !piece.placed else { return }
                isDragging = true
                viewModel.updateDrag(piece.id, to: value.location)
            }
            .onEnded { _ in
                isDragging = false
                // The celebration line takes over when this was the final piece.
                if viewModel.endDrag(piece.id), !viewModel.celebrate {
                    narration.speak(piece.animal.localizedName)
                }
            }
    }
}

/// The drop target: an outlined frame holding the animal's shadow silhouette.
private struct AnimalMatchDropFrame: View {
    let animal: Animal
    let placed: Bool

    @Environment(\.pace) private var pace

    var body: some View {
        AnimalShadowTarget(animal: animal, size: AnimalMatchViewModel.pieceSize, placed: placed)
            .animation(pace.fastAnimation, value: placed)
            .accessibilityLabel(animal.nameKey)
            .accessibilityValue(Text("animalMatchTargetA11y"))
    }
}

private struct AnimalMatchTray: View {
    let viewModel: AnimalMatchViewModel

    @Environment(\.palette) private var palette

    var body: some View {
        HStack {
            Text("animalMatchTrayLabel")
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

#Preview("Animal Shadow Match — warm") {
    NavigationStack {
        AnimalMatchView()
            .environment(\.palette, .warm)
            .environment(AnimalProgressStore())
            .environment(NarrationService(profile: ProfileStore()))
    }
}
