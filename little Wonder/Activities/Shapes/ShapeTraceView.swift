import SwiftUI

struct ShapeTraceView: View {
    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss
    @Environment(ShapeProgressStore.self) private var progress
    @State private var viewModel = ShapeTraceViewModel()

    var body: some View {
        ActivityStage(
            kicker: "shapeTraceKicker",
            title: "shapeTraceTitle",
            prompt: "shapeTracePrompt",
            progress: AnyView(ProgressDots(count: viewModel.shapes.count, active: viewModel.activeIndex)),
            onClose: { dismiss() },
            onReset: { viewModel.reset() },
            onSpeak: { /* TODO: AVSpeechSynthesizer */ }
        ) {
            HStack(spacing: 28) {
                ShapeTraceRail(viewModel: viewModel)
                    .frame(width: 180)
                ShapeTraceBoard(viewModel: viewModel)
            }
            .task {
                viewModel.onComplete = { [progress] in progress.recordTrace() }
            }
        }
    }
}

private struct ShapeTraceRail: View {
    let viewModel: ShapeTraceViewModel

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("shapeTracePickKicker")
                .font(FontStack.mono)
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)

            ForEach(viewModel.shapes, id: \.self) { kind in
                ShapeTraceRailButton(
                    kind: kind,
                    isActive: kind == viewModel.activeShape,
                    isDone: viewModel.completed.contains(kind)
                ) {
                    viewModel.selectShape(kind)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(palette.sand, in: .rect(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(palette.line, lineWidth: 1)
        }
    }
}

private struct ShapeTraceRailButton: View {
    let kind: ShapeKind
    let isActive: Bool
    let isDone: Bool
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm + 2) {
                PrimitiveShape(kind: kind, size: 28, fill: isActive ? palette.paperHi : palette.ink)
                    .frame(width: 28, height: 28)
                Text(label)
                    .font(.system(.callout, design: .rounded).weight(.medium))
                    .foregroundStyle(isActive ? palette.paperHi : palette.ink)
                    .italic(isDone)
                Spacer()
                if isDone {
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(palette.inkSoft)
                }
            }
            .padding(.horizontal, Spacing.md - 2)
            .padding(.vertical, Spacing.sm + 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isActive ? palette.ink : .clear, in: .rect(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(palette.line, lineWidth: isActive ? 0 : 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var label: LocalizedStringKey {
        switch kind {
        case .circle:   "shapeKindCircle"
        case .square:   "shapeKindSquare"
        case .triangle: "shapeKindTriangle"
        case .star:     "shapeKindStar"
        case .heart:    "shapeKindHeart"
        case .diamond:  "shapeKindDiamond"
        case .hexagon:  "shapeKindHexagon"
        default:        "shapeKindCircle"
        }
    }
}

private struct ShapeTraceBoard: View {
    let viewModel: ShapeTraceViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    private let logical = CGSize(width: 760, height: 540)

    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / logical.width, proxy.size.height / logical.height)
            let shapeRect = CGRect(x: 180, y: 70, width: 400, height: 400)
            let dots = viewModel.dots(in: shapeRect)

            ZStack(alignment: .topLeading) {
                palette.paper

                gridOverlay
                    .opacity(0.5)
                    .frame(width: logical.width, height: logical.height)

                PrimitiveShape(
                    kind: viewModel.activeShape,
                    size: shapeRect.width,
                    stroke: palette.line,
                    strokeWidth: 3
                )
                .position(x: shapeRect.midX, y: shapeRect.midY)
                .opacity(0.6)

                tracedArc(dots: dots, in: shapeRect)

                ForEach(Array(dots.enumerated()), id: \.offset) { idx, point in
                    Circle()
                        .fill(idx < viewModel.filled ? palette.terracotta : palette.paperHi)
                        .frame(width: idx < viewModel.filled ? 10 : 8, height: idx < viewModel.filled ? 10 : 8)
                        .overlay {
                            if idx >= viewModel.filled {
                                Circle().stroke(palette.line, lineWidth: 1)
                            }
                        }
                        .position(point)
                }

                if let first = dots.first {
                    Circle()
                        .stroke(palette.sage, lineWidth: 3)
                        .frame(width: 24, height: 24)
                        .position(first)
                }
                if let last = dots.last {
                    Circle()
                        .stroke(palette.berry, lineWidth: 3)
                        .frame(width: 24, height: 24)
                        .position(last)
                }

                if viewModel.filled < dots.count, viewModel.filled >= 0, dots.indices.contains(viewModel.filled) {
                    let target = dots[viewModel.filled]
                    Circle()
                        .fill(palette.terracotta.opacity(0.18))
                        .frame(width: 52, height: 52)
                        .position(target)
                }

                ShapeTraceCounter(filled: viewModel.filled, total: dots.count)
                    .padding(18)
                    .frame(width: logical.width, height: logical.height, alignment: .topTrailing)
            }
            .frame(width: logical.width, height: logical.height)
            .contentShape(.rect)
            .coordinateSpace(name: "traceStage")
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named("traceStage"))
                    .onChanged { value in
                        viewModel.progress(touch: value.location, dots: dots)
                    }
                    .onEnded { _ in
                        if viewModel.filled == dots.count {
                            withAnimation(pace.baseAnimation) {
                                viewModel.advanceShape()
                            }
                        }
                    }
            )
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: logical.width * scale, height: logical.height * scale, alignment: .topLeading)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(palette.paper)
            .clipShape(.rect(cornerRadius: 26, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(palette.line, style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            }
        }
    }

    private var gridOverlay: some View {
        Canvas { ctx, size in
            let step: CGFloat = 40
            var path = Path()
            for x in stride(from: 0, through: size.width, by: step) {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, through: size.height, by: step) {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            ctx.stroke(path, with: .color(palette.line.opacity(0.5)), lineWidth: 0.5)
        }
    }

    @ViewBuilder
    private func tracedArc(dots: [CGPoint], in rect: CGRect) -> some View {
        if viewModel.filled > 1 {
            Path { path in
                let prefix = Array(dots.prefix(viewModel.filled))
                guard let first = prefix.first else { return }
                path.move(to: first)
                for pt in prefix.dropFirst() {
                    path.addLine(to: pt)
                }
            }
            .stroke(palette.terracotta.opacity(0.92), style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round))
        }
    }
}

private struct ShapeTraceCounter: View {
    let filled: Int
    let total: Int

    @Environment(\.palette) private var palette

    var body: some View {
        Text("shapeTraceDotsCount \(filled) \(total)")
            .font(FontStack.mono)
            .padding(.horizontal, Spacing.md - 2)
            .padding(.vertical, Spacing.sm)
            .background(palette.paperHi, in: .capsule)
            .overlay { Capsule().stroke(palette.line, lineWidth: 1) }
            .foregroundStyle(palette.ink)
    }
}
