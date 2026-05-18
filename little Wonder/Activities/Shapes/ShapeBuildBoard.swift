import SwiftUI

/// Shared board UI for Build and Free play. The differing toolbar/footer copy
/// lives on the host views.
struct ShapeBuildBoard: View {
    let viewModel: ShapeBuildViewModel
    var showsFooter: Bool

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(ProfileStore.self) private var profile

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                ShapeBuildRail(viewModel: viewModel)
                    .frame(width: 130)

                ShapeBuildCanvas(viewModel: viewModel)
            }

            if showsFooter {
                ShapeBuildFooter(viewModel: viewModel, ownerName: profile.displayName)
            }
        }
    }
}

private struct ShapeBuildRail: View {
    let viewModel: ShapeBuildViewModel

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md - 4) {
            Text("shapeBuildToyBoxKicker")
                .font(FontStack.mono)
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.toyBox) { item in
                        ShapeBuildRailTile(item: item, viewModel: viewModel)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(palette.sand, in: .rect(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(palette.line, lineWidth: 1)
        }
    }
}

private struct ShapeBuildRailTile: View {
    let item: ShapeBuildViewModel.ToyBoxItem
    let viewModel: ShapeBuildViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        Button {
            // Tapping spawns near the center of the canvas; child can drag from there.
            viewModel.spawn(item, at: CGPoint(x: 400, y: 260))
        } label: {
            ZStack(alignment: .topTrailing) {
                PrimitiveShape(kind: item.kind, size: 54, fill: palette[keyPath: item.color])
                Text("×∞")
                    .font(FontStack.mono)
                    .foregroundStyle(palette.inkSoft)
                    .padding(4)
            }
            .frame(width: 90, height: 90)
            .background(palette.paperHi, in: .rect(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(palette.line, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("shapeA11y \(item.kind.rawValue)"))
    }
}

private struct ShapeBuildCanvas: View {
    let viewModel: ShapeBuildViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    private let logical = CGSize(width: 800, height: 540)

    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / logical.width, proxy.size.height / logical.height)
            ZStack {
                LinearGradient(
                    colors: [palette.sky.opacity(0.13), palette.paper],
                    startPoint: .top,
                    endPoint: .bottom
                )

                ForEach(viewModel.pieces) { piece in
                    ShapeBuildPieceView(piece: piece, viewModel: viewModel)
                }

                VStack {
                    HStack {
                        Text("shapeBuildCanvasKicker \(viewModel.pieceCount)")
                            .font(FontStack.mono)
                            .padding(.horizontal, Spacing.md - 2)
                            .padding(.vertical, Spacing.sm)
                            .background(palette.paperHi, in: .capsule)
                            .overlay { Capsule().stroke(palette.line, lineWidth: 1) }
                        Spacer()
                        HStack(spacing: Spacing.sm) {
                            RoundIconButton(label: "shapeStageReset", systemImage: "arrow.counterclockwise", size: 42) { viewModel.reset() }
                            RoundIconButton(label: "shapeBuildClear", systemImage: "trash", size: 42) { viewModel.clear() }
                        }
                    }
                    Spacer()
                }
                .padding(18)
            }
            .frame(width: logical.width, height: logical.height)
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: logical.width * scale, height: logical.height * scale, alignment: .topLeading)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(.rect(cornerRadius: 26, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(palette.line, lineWidth: 1.5)
            }
        }
    }
}

private struct ShapeBuildPieceView: View {
    let piece: ShapeBuildViewModel.PlacedPiece
    let viewModel: ShapeBuildViewModel

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        PrimitiveShape(kind: piece.kind, size: 120, fill: palette[keyPath: piece.color])
            .scaleEffect(piece.scale)
            .rotationEffect(piece.rotation)
            .position(x: piece.position.x + dragOffset.width,
                      y: piece.position.y + dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in dragOffset = value.translation }
                    .onEnded { value in
                        let final = CGPoint(
                            x: piece.position.x + value.translation.width,
                            y: piece.position.y + value.translation.height
                        )
                        dragOffset = .zero
                        viewModel.move(piece.id, to: final)
                    }
            )
    }
}

private struct ShapeBuildFooter: View {
    let viewModel: ShapeBuildViewModel
    let ownerName: String

    @Environment(\.palette) private var palette

    var body: some View {
        HStack {
            Text(caption)
                .font(.system(.callout, design: .serif).italic())
                .foregroundStyle(palette.inkSoft)
            Spacer()
            PillButton(title: "shapeBuildPinAction", kind: .primary, size: .sm) {
                // TODO: render thumbnail via ImageRenderer and persist via SwiftData.
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private var caption: String {
        let date = Date.now.formatted(date: .abbreviated, time: .omitted)
        return String(localized: "shapeBuildSaveCaption \(ownerName) \(date)")
    }
}
