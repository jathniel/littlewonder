import SwiftUI

/// Board UI for the animal free-play scene pad. Mirrors `ColorStampBoard`.
struct AnimalStampBoard: View {
    let viewModel: AnimalStampViewModel

    var body: some View {
        HStack(spacing: Spacing.md) {
            AnimalStampRail(viewModel: viewModel)
                .frame(width: 130)
            AnimalStampCanvas(viewModel: viewModel)
        }
    }
}

private struct AnimalStampRail: View {
    let viewModel: AnimalStampViewModel

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md - 4) {
            Text("animalStampToyBoxKicker")
                .font(FontStack.mono)
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.toyBox) { item in
                        AnimalStampRailTile(item: item, viewModel: viewModel)
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

private struct AnimalStampRailTile: View {
    let item: AnimalStampViewModel.ToyBoxItem
    let viewModel: AnimalStampViewModel

    @Environment(\.palette) private var palette

    var body: some View {
        Button {
            viewModel.spawn(item, at: CGPoint(x: 400, y: 260))
        } label: {
            AnimalGlyph(animal: item.animal, size: 64)
                .frame(width: 90, height: 90)
                .background(palette.paperHi, in: .rect(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(palette.line, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.animal.nameKey)
    }
}

private struct AnimalStampCanvas: View {
    let viewModel: AnimalStampViewModel

    @Environment(\.palette) private var palette

    private let logical = CGSize(width: 800, height: 540)

    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / logical.width, proxy.size.height / logical.height)
            ZStack {
                LinearGradient(
                    colors: [palette.animals.opacity(0.13), palette.paper],
                    startPoint: .top,
                    endPoint: .bottom
                )

                ForEach(viewModel.pieces) { piece in
                    AnimalStampPieceView(piece: piece, viewModel: viewModel)
                }

                VStack {
                    HStack {
                        Text("animalStampCanvasKicker \(viewModel.pieceCount)")
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

private struct AnimalStampPieceView: View {
    let piece: AnimalStampViewModel.PlacedPiece
    let viewModel: AnimalStampViewModel

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        AnimalGlyph(animal: piece.animal, size: 110)
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
            .accessibilityLabel(piece.animal.nameKey)
    }
}
