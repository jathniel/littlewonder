import SwiftUI

struct NumbersRoomView: View {
    @Binding var path: NavigationPath

    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var hSize
    @State private var isPortrait = UIDevice.current.orientation.isPortrait

    @Environment(NumberProgressStore.self) private var progress

    private let activities: [NumberActivityID] = [.count, .match, .order, .freePlay]

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
            NumbersRoomRail(progress: progress, onBack: { dismiss() })
                .frame(maxWidth: 360, alignment: .topLeading)
            NumbersRoomGrid(activities: activities, isCompactWidth: false) { activity in
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
                NumbersRoomGrid(activities: activities, isCompactWidth: true) { activity in
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
            TopicBadge(label: "topicNumbers", accent: \Palette.numbers)
            Spacer(minLength: Spacing.md)
            RoundIconButton(label: "audioToggle", systemImage: "speaker.wave.2.fill", size: 48) { }
            RoundIconButton(label: "numberRoomFavoritesButton", systemImage: "target", size: 48) { }
        }
    }

    private var compactHero: some View {
        HStack(alignment: .top, spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("numberRoomTitle")
                    .font(.system(.largeTitle, design: .serif))
                    .kerning(-1.2)
                    .foregroundStyle(palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("numberRoomBlurb")
                    .font(.system(.callout, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)

            NumbersRoomWeeklyCard(progress: progress)
                .frame(maxWidth: .infinity)
        }
    }
}

private struct NumbersRoomRail: View {
    let progress: NumberProgressStore
    let onBack: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md + 6) {
            HStack(spacing: Spacing.md) {
                RoundIconButton(label: "topicPlaceholderBack", systemImage: "chevron.left", size: 48, action: onBack)
                TopicBadge(label: "topicNumbers", accent: \Palette.numbers)
            }

            Text("numberRoomTitle")
                .font(.system(size: 64, weight: .regular, design: .serif))
                .kerning(-1.8)
                .foregroundStyle(palette.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("numberRoomBlurb")
                .font(.system(.callout, design: .rounded).weight(.medium))
                .foregroundStyle(palette.inkSoft)
                .fixedSize(horizontal: false, vertical: true)

            NumbersRoomWeeklyCard(progress: progress)

            Spacer(minLength: 0)

            HStack(spacing: Spacing.sm + 4) {
                RoundIconButton(label: "audioToggle", systemImage: "speaker.wave.2.fill", size: 48) { }
                RoundIconButton(label: "numberRoomFavoritesButton", systemImage: "target", size: 48) { }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct NumbersRoomWeeklyCard: View {
    let progress: NumberProgressStore

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md - 2) {
            Text("numberWeeklyKicker")
                .font(FontStack.mono)
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)

            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm + 2) {
                Text(progress.numbersPlayedThisWeek, format: .number)
                    .font(.system(size: 56, weight: .regular, design: .serif))
                    .kerning(-1)
                    .foregroundStyle(palette.ink)
                Text("numberWeeklyValueUnit")
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
            }

            HStack(spacing: 6) {
                ForEach(progress.weekActivity.indices, id: \.self) { idx in
                    Capsule(style: .continuous)
                        .fill(progress.weekActivity[idx] ? palette.numbers : palette.line)
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

private struct NumbersRoomGrid: View {
    let activities: [NumberActivityID]
    let isCompactWidth: Bool
    let onSelect: (NumberActivityID) -> Void

    private var columnCount: Int { isCompactWidth ? 2 : 3 }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: columnCount)
    }

    private var standardTiles: [NumberActivityID] { activities.filter { !$0.isWide } }
    private var wideTiles: [NumberActivityID] { activities.filter(\.isWide) }

    private let tileHeight: CGFloat = 260

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(standardTiles) { activity in
                NumbersRoomTile(activity: activity, onSelect: onSelect)
                    .frame(height: tileHeight)
            }

            // In regular width (3 columns) the three standard tiles fill row 1, so the
            // wide free-play tile sits on row 2 spanning columns 1–2. In compact width
            // (2 columns) the wide tile lands on its own row.
            ForEach(wideTiles) { activity in
                NumbersRoomTile(activity: activity, onSelect: onSelect)
                    .frame(height: tileHeight)
                    .gridCellColumns(2)
            }
        }
    }
}

private struct NumbersRoomTile: View {
    let activity: NumberActivityID
    let onSelect: (NumberActivityID) -> Void

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
        case .count:    NumberCountTileArt()
        case .match:    NumberMatchTileArt()
        case .order:    NumberOrderTileArt()
        case .freePlay: NumberFreePlayTileArt()
        }
    }
}

#Preview("Number Room — warm") {
    NumbersRoomPreviewHarness(palette: .warm)
}

#Preview("Number Room — compact width") {
    NumbersRoomPreviewHarness(palette: .warm)
        .environment(\.horizontalSizeClass, .compact)
}

private struct NumbersRoomPreviewHarness: View {
    let palette: Palette
    @State private var path = NavigationPath()
    @State private var progress = NumberProgressStore()

    var body: some View {
        NavigationStack(path: $path) {
            NumbersRoomView(path: $path)
                .environment(\.palette, palette)
                .environment(progress)
        }
    }
}
