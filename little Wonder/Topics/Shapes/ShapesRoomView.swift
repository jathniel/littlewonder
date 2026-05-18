import SwiftUI

struct ShapesRoomView: View {
    @Binding var path: NavigationPath

    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var hSize
    @State private var isPortrait = UIDevice.current.orientation.isPortrait

    @State private var progress = ShapeProgressStore()

    private let activities: [ShapeActivityID] = [.match, .sort, .trace, .build, .freePlay]

    private var isCompactWidth: Bool { hSize == .compact }

    var body: some View {
        ZStack {
            palette.paper.ignoresSafeArea()

            if isPortrait || isCompactWidth {
                compactBody
            } else {
                regularBody
            }
        }
        .navigationBarBackButtonHidden()
    }

    private var regularBody: some View {
        HStack(alignment: .top, spacing: Spacing.lg) {
            ShapesRoomRail(progress: progress, onBack: { dismiss() })
                .frame(maxWidth: 360, alignment: .topLeading)
            ShapesRoomGrid(activities: activities, isCompactWidth: false) { activity in
                path.append(activity)
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.xl + Spacing.lg)
        .padding(.bottom, Spacing.xl)
    }

    private var compactBody: some View {
        ScrollView {
            VStack(alignment: .center, spacing: Spacing.lg) {
                compactToolbar
                compactHero
                ShapesRoomGrid(activities: activities, isCompactWidth: true) { activity in
                    path.append(activity)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
        .scrollIndicators(.hidden)
    }

    private var compactToolbar: some View {
        HStack(spacing: Spacing.md) {
            RoundIconButton(label: "topicPlaceholderBack", systemImage: "chevron.left", size: 48) { dismiss() }
            TopicBadge(label: "topicShapes", accent: \Palette.shapes)
            Spacer(minLength: Spacing.md)
            RoundIconButton(label: "audioToggle", systemImage: "speaker.wave.2.fill", size: 48) { }
            RoundIconButton(label: "shapeRoomFavoritesButton", systemImage: "target", size: 48) { }
        }
    }

    private var compactHero: some View {
        HStack(alignment: .top, spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("shapeRoomTitle")
                    .font(.system(.largeTitle, design: .serif))
                    .kerning(-1.2)
                    .foregroundStyle(palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("shapeRoomBlurb")
                    .font(.system(.callout, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)

            ShapesRoomWeeklyCard(progress: progress)
                .frame(maxWidth: .infinity)
        }
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
        .padding(Spacing.lg - 2)
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
    let isCompactWidth: Bool
    let onSelect: (ShapeActivityID) -> Void

    private var columnCount: Int { isCompactWidth ? 2 : 3 }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: columnCount)
    }

    private var standardTiles: [ShapeActivityID] { activities.filter { !$0.isWide } }
    private var wideTiles: [ShapeActivityID] { activities.filter(\.isWide) }

    /// Larger than the original 230pt so tiles read as friendly tap targets for young kids.
    private let tileHeight: CGFloat = 260

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(standardTiles) { activity in
                ShapesRoomTile(activity: activity, onSelect: onSelect)
                    .frame(height: tileHeight)
            }

            // In regular width (3 columns) the wide free-play tile spans columns 2–3,
            // so insert an empty cell to keep the first column aligned. In compact
            // width (2 columns) the four standard tiles fill rows 1–2 exactly and
            // the wide tile lands on its own row — no spacer needed.
            if !isCompactWidth {
                Color.clear
                    .frame(height: tileHeight)
            }

            ForEach(wideTiles) { activity in
                ShapesRoomTile(activity: activity, onSelect: onSelect)
                    .frame(height: tileHeight)
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

#Preview("Shape Room — compact width") {
    ShapesRoomPreviewHarness(palette: .warm)
        .environment(\.horizontalSizeClass, .compact)
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
