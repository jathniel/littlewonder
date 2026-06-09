import SwiftUI

struct ColorsRoomView: View {
    @Binding var path: NavigationPath

    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var hSize
    @State private var isPortrait = UIDevice.current.orientation.isPortrait

    @Environment(ColorProgressStore.self) private var progress

    private let activities: [ColorActivityID] = [.match, .sort, .find, .mix, .freePlay]

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
            ColorsRoomRail(progress: progress, onBack: { dismiss() })
                .frame(maxWidth: 360, alignment: .topLeading)
            ColorsRoomGrid(activities: activities, isCompactWidth: false) { activity in
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
                ColorsRoomGrid(activities: activities, isCompactWidth: true) { activity in
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
            TopicBadge(label: "topicColors", accent: \Palette.colors)
            Spacer(minLength: Spacing.md)
            RoundIconButton(label: "audioToggle", systemImage: "speaker.wave.2.fill", size: 48) { }
            RoundIconButton(label: "colorRoomFavoritesButton", systemImage: "target", size: 48) { }
        }
    }

    private var compactHero: some View {
        HStack(alignment: .top, spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("colorRoomTitle")
                    .font(.system(.largeTitle, design: .serif))
                    .kerning(-1.2)
                    .foregroundStyle(palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("colorRoomBlurb")
                    .font(.system(.callout, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)

            ColorsRoomWeeklyCard(progress: progress)
                .frame(maxWidth: .infinity)
        }
    }
}

private struct ColorsRoomRail: View {
    let progress: ColorProgressStore
    let onBack: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md + 6) {
            HStack(spacing: Spacing.md) {
                RoundIconButton(label: "topicPlaceholderBack", systemImage: "chevron.left", size: 48, action: onBack)
                TopicBadge(label: "topicColors", accent: \Palette.colors)
            }

            Text("colorRoomTitle")
                .font(.system(size: 64, weight: .regular, design: .serif))
                .kerning(-1.8)
                .foregroundStyle(palette.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("colorRoomBlurb")
                .font(.system(.callout, design: .rounded).weight(.medium))
                .foregroundStyle(palette.inkSoft)
                .fixedSize(horizontal: false, vertical: true)

            ColorsRoomWeeklyCard(progress: progress)

            Spacer(minLength: 0)

            HStack(spacing: Spacing.sm + 4) {
                RoundIconButton(label: "audioToggle", systemImage: "speaker.wave.2.fill", size: 48) { }
                RoundIconButton(label: "colorRoomFavoritesButton", systemImage: "target", size: 48) { }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct ColorsRoomWeeklyCard: View {
    let progress: ColorProgressStore

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md - 2) {
            Text("colorWeeklyKicker")
                .font(FontStack.mono)
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)

            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm + 2) {
                Text(progress.colorsPlayedThisWeek, format: .number)
                    .font(.system(size: 56, weight: .regular, design: .serif))
                    .kerning(-1)
                    .foregroundStyle(palette.ink)
                Text("colorWeeklyValueUnit")
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
            }

            HStack(spacing: 6) {
                ForEach(progress.weekActivity.indices, id: \.self) { idx in
                    Capsule(style: .continuous)
                        .fill(progress.weekActivity[idx] ? palette.colors : palette.line)
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

private struct ColorsRoomGrid: View {
    let activities: [ColorActivityID]
    let isCompactWidth: Bool
    let onSelect: (ColorActivityID) -> Void

    private var columnCount: Int { isCompactWidth ? 2 : 3 }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: columnCount)
    }

    private var standardTiles: [ColorActivityID] { activities.filter { !$0.isWide } }
    private var wideTiles: [ColorActivityID] { activities.filter(\.isWide) }

    private let tileHeight: CGFloat = 260

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(standardTiles) { activity in
                ColorsRoomTile(activity: activity, onSelect: onSelect)
                    .frame(height: tileHeight)
            }

            // The wide Free Play tile spans two columns on the next row.
            ForEach(wideTiles) { activity in
                ColorsRoomTile(activity: activity, onSelect: onSelect)
                    .frame(height: tileHeight)
                    .gridCellColumns(2)
            }
        }
    }
}

private struct ColorsRoomTile: View {
    let activity: ColorActivityID
    let onSelect: (ColorActivityID) -> Void

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
        case .match:    ColorMatchTileArt()
        case .sort:     ColorSortTileArt()
        case .find:     ColorFindTileArt()
        case .mix:      ColorMixTileArt()
        case .freePlay: ColorFreePlayTileArt()
        }
    }
}

#Preview("Colour Room — warm") {
    ColorsRoomPreviewHarness(palette: .warm)
}

#Preview("Colour Room — compact width") {
    ColorsRoomPreviewHarness(palette: .warm)
        .environment(\.horizontalSizeClass, .compact)
}

private struct ColorsRoomPreviewHarness: View {
    let palette: Palette
    @State private var path = NavigationPath()
    @State private var progress = ColorProgressStore()

    var body: some View {
        NavigationStack(path: $path) {
            ColorsRoomView(path: $path)
                .environment(\.palette, palette)
                .environment(progress)
        }
    }
}
