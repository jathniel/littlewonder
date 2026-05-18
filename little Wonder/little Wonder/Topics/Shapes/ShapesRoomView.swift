import SwiftUI

struct ShapesRoomView: View {
    @Binding var path: NavigationPath

    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss
    @State private var progress = ShapeProgressStore()

    private let activities: [ShapeActivityID] = [.match, .sort, .trace, .build, .freePlay]

    var body: some View {
        ZStack {
            palette.paper.ignoresSafeArea()

            HStack(alignment: .top, spacing: 32) {
                ShapesRoomRail(progress: progress, onBack: { dismiss() })
                    .frame(width: 360)
                ShapesRoomGrid(activities: activities) { activity in
                    path.append(activity)
                }
            }
            .padding(.leading, 56)
            .padding(.trailing, 56)
            .padding(.top, 80)
            .padding(.bottom, 56)
        }
        .navigationBarBackButtonHidden()
    }
}

private struct ShapesRoomRail: View {
    let progress: ShapeProgressStore
    let onBack: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md + 6) {
            HStack(spacing: Spacing.md) {
                RoundIconButton(label: "topicPlaceholderBack", systemImage: "chevron.left", size: 48, action: onBack)
                TopicBadge(label: "topicShapes", accent: \Palette.shapes)
            }

            Text("shapeRoomTitle")
                .font(.system(size: 64, weight: .regular, design: .serif))
                .kerning(-1.8)
                .foregroundStyle(palette.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("shapeRoomBlurb")
                .font(.system(.callout, design: .rounded).weight(.medium))
                .foregroundStyle(palette.inkSoft)
                .fixedSize(horizontal: false, vertical: true)

            ShapesRoomWeeklyCard(progress: progress)

            Spacer(minLength: 0)

            HStack(spacing: Spacing.sm + 4) {
                RoundIconButton(label: "audioToggle", systemImage: "speaker.wave.2.fill", size: 48) { }
                RoundIconButton(label: "shapeRoomFavoritesButton", systemImage: "target", size: 48) { }
            }
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct ShapesRoomWeeklyCard: View {
    let progress: ShapeProgressStore

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md - 2) {
            Text("shapeWeeklyKicker")
                .font(FontStack.mono)
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)

            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm + 2) {
                Text(progress.matchesMadeThisWeek, format: .number)
                    .font(.system(size: 56, weight: .regular, design: .serif))
                    .kerning(-1)
                    .foregroundStyle(palette.ink)
                Text("shapeWeeklyValueUnit")
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
            }

            HStack(spacing: 6) {
                ForEach(progress.weekActivity.indices, id: \.self) { idx in
                    Capsule(style: .continuous)
                        .fill(progress.weekActivity[idx] ? palette.shapes : palette.line)
                        .frame(height: 8)
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.paperHi, in: .rect(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(palette.line, lineWidth: 1)
        }
    }
}

private struct ShapesRoomGrid: View {
    let activities: [ShapeActivityID]
    let onSelect: (ShapeActivityID) -> Void

    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 18),
        count: 3
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 18) {
            ForEach(activities.filter { !$0.isWide }) { activity in
                ShapesRoomTile(activity: activity, onSelect: onSelect)
                    .frame(height: 230)
            }

            // Free play spans columns 2-3 on the second row;
            // leave the first cell of row 2 empty by inserting an empty colored block.
            Color.clear
                .frame(height: 230)

            ForEach(activities.filter(\.isWide)) { activity in
                ShapesRoomTile(activity: activity, onSelect: onSelect)
                    .frame(height: 230)
                    .gridCellColumns(2)
            }
        }
    }
}

private struct ShapesRoomTile: View {
    let activity: ShapeActivityID
    let onSelect: (ShapeActivityID) -> Void

    var body: some View {
        ActivityTile(
            title: activity.titleKey,
            subtitle: activity.subtitleKey,
            accent: activity.accent,
            isWide: activity.isWide
        ) {
            tileArt
        } action: {
            onSelect(activity)
        }
    }

    @ViewBuilder
    private var tileArt: some View {
        switch activity {
        case .match:    ShapeMatchTileArt()
        case .sort:     ShapeSortTileArt()
        case .trace:    ShapeTraceTileArt()
        case .build:    ShapeBuildTileArt()
        case .freePlay: ShapeFreePlayTileArt()
        }
    }
}

#Preview("Shape Room — warm") {
    ShapesRoomPreviewHarness(palette: .warm)
}

#Preview("Shape Room — cool") {
    ShapesRoomPreviewHarness(palette: .cool)
}

private struct ShapesRoomPreviewHarness: View {
    let palette: Palette
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ShapesRoomView(path: $path)
                .environment(\.palette, palette)
        }
    }
}
