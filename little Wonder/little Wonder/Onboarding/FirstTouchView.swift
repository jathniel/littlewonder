import SwiftUI

struct FirstTouchView: View {
    let onAdvance: () -> Void

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    @State private var dragOffset: CGSize = .zero
    @State private var isPlaced = false
    @State private var nudgePhase: CGFloat = 0

    @ScaledMetric private var pieceSize: CGFloat = 150
    @ScaledMetric private var outlineSize: CGFloat = 160
    @ScaledMetric private var gap: CGFloat = 80

    private var snapDeltaX: CGFloat {
        pieceSize / 2 + gap + outlineSize / 2
    }

    var body: some View {
        ZStack {
            palette.paper.ignoresSafeArea()
            FirstTouchHeader()
            FirstTouchStage(
                pieceSize: pieceSize,
                outlineSize: outlineSize,
                gap: gap,
                snapDeltaX: snapDeltaX,
                dragOffset: $dragOffset,
                isPlaced: $isPlaced,
                nudgePhase: $nudgePhase,
                onSnapComplete: scheduleAdvance
            )
            FirstTouchFooter()
        }
    }

    private func scheduleAdvance() {
        Task { @MainActor in
            try? await Task.sleep(for: pace.base)
            onAdvance()
        }
    }
}

private struct FirstTouchHeader: View {
    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("firstTouchKicker")
                .font(FontStack.mono)
                .kerning(2)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)

            Text("firstTouchHeadline")
                .font(.system(.largeTitle, design: .serif))
                .kerning(-1.2)
                .foregroundStyle(palette.ink)
                .padding(.top, Spacing.md - 2)
        }
        .padding(.horizontal, Spacing.xxl - 8)
        .padding(.top, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct FirstTouchFooter: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack {
            HStack(spacing: Spacing.sm + 4) {
                RoundIconButton(
                    label: "audioToggle",
                    systemImage: "speaker.wave.2.fill",
                    size: 48
                ) { }
                Text("firstTouchHint")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(palette.inkSoft)
            }
            Spacer()
            ProgressDots(count: 3, active: 2)
        }
        .padding(.horizontal, Spacing.xxl - 8)
        .padding(.bottom, Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

private struct FirstTouchStage: View {
    let pieceSize: CGFloat
    let outlineSize: CGFloat
    let gap: CGFloat
    let snapDeltaX: CGFloat

    @Binding var dragOffset: CGSize
    @Binding var isPlaced: Bool
    @Binding var nudgePhase: CGFloat
    let onSnapComplete: () -> Void

    var body: some View {
        HStack(spacing: gap) {
            FirstTouchDraggable(
                pieceSize: pieceSize,
                snapDeltaX: snapDeltaX,
                dragOffset: $dragOffset,
                isPlaced: $isPlaced,
                nudgePhase: $nudgePhase,
                onSnapComplete: onSnapComplete
            )
            FirstTouchOutline(outlineSize: outlineSize, isPlaced: isPlaced)
        }
    }
}

private struct FirstTouchDraggable: View {
    let pieceSize: CGFloat
    let snapDeltaX: CGFloat

    @Binding var dragOffset: CGSize
    @Binding var isPlaced: Bool
    @Binding var nudgePhase: CGFloat
    let onSnapComplete: () -> Void

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let offsetX: CGFloat = {
            if isPlaced { return snapDeltaX }
            if dragOffset == .zero { return nudgePhase }
            return dragOffset.width
        }()
        let offsetY: CGFloat = isPlaced ? 0 : dragOffset.height

        PrimitiveShape(kind: .circle, size: pieceSize, fill: palette.terracotta)
            .offset(x: offsetX, y: offsetY)
            .gesture(dragGesture)
            .onAppear {
                guard !isPlaced, !reduceMotion else { return }
                withAnimation(pace.animation(pace.long * 2).repeatForever(autoreverses: true)) {
                    nudgePhase = 36
                }
            }
            .accessibilityLabel(Text("firstTouchPieceLabel"))
            .accessibilityHint(Text("firstTouchPieceHint"))
            .accessibilityAction(.default) {
                withAnimation(pace.baseAnimation) {
                    isPlaced = true
                    dragOffset = .zero
                }
                onSnapComplete()
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard !isPlaced else { return }
                dragOffset = value.translation
            }
            .onEnded { value in
                guard !isPlaced else { return }
                let drop = CGPoint(x: value.translation.width, y: value.translation.height)
                let target = CGPoint(x: snapDeltaX, y: 0)
                let snap = dragSnapResult(from: drop, to: target)
                if snap.isInRange {
                    withAnimation(pace.baseAnimation) {
                        isPlaced = true
                        dragOffset = .zero
                    }
                    onSnapComplete()
                } else {
                    withAnimation(pace.baseAnimation) {
                        dragOffset = .zero
                    }
                }
            }
    }
}

private struct FirstTouchOutline: View {
    let outlineSize: CGFloat
    let isPlaced: Bool

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(palette.line, style: StrokeStyle(lineWidth: 3, dash: [8, 6]))
                .frame(width: outlineSize, height: outlineSize)
            Circle()
                .stroke(palette.shapes, lineWidth: 2)
                .frame(width: outlineSize + 20, height: outlineSize + 20)
                .opacity(0.6)
        }
        .opacity(isPlaced ? 0 : 1)
        .animation(pace.fastAnimation, value: isPlaced)
        .accessibilityHidden(true)
    }
}
