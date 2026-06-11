import SwiftUI

struct AnimalsRoomView: View {
    @Binding var path: NavigationPath

    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var hSize
    @State private var isPortrait = UIDevice.current.orientation.isPortrait

    @Environment(AnimalProgressStore.self) private var progress

    private let activities: [AnimalActivityID] = [.match, .sort, .find, .freePlay]

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
            AnimalsRoomRail(progress: progress, onBack: { dismiss() })
                .frame(maxWidth: 360, alignment: .topLeading)
            AnimalsRoomGrid(activities: activities, isCompactWidth: false) { activity in
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
                AnimalsRoomGrid(activities: activities, isCompactWidth: true) { activity in
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
            TopicBadge(label: "topicAnimals", accent: \Palette.animals)
            Spacer(minLength: Spacing.md)
            RoundIconButton(label: "audioToggle", systemImage: "speaker.wave.2.fill", size: 48) { }
            RoundIconButton(label: "animalRoomFavoritesButton", systemImage: "pawprint.fill", size: 48) { }
        }
    }

    private var compactHero: some View {
        HStack(alignment: .top, spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("animalRoomTitle")
                    .font(.system(.largeTitle, design: .serif))
                    .kerning(-1.2)
                    .foregroundStyle(palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("animalRoomBlurb")
                    .font(.system(.callout, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)

            AnimalsRoomWeeklyCard(progress: progress)
                .frame(maxWidth: .infinity)
        }
    }
}

private struct AnimalsRoomRail: View {
    let progress: AnimalProgressStore
    let onBack: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md + 6) {
            HStack(spacing: Spacing.md) {
                RoundIconButton(label: "topicPlaceholderBack", systemImage: "chevron.left", size: 48, action: onBack)
                TopicBadge(label: "topicAnimals", accent: \Palette.animals)
            }

            Text("animalRoomTitle")
                .font(.system(size: 64, weight: .regular, design: .serif))
                .kerning(-1.8)
                .foregroundStyle(palette.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("animalRoomBlurb")
                .font(.system(.callout, design: .rounded).weight(.medium))
                .foregroundStyle(palette.inkSoft)
                .fixedSize(horizontal: false, vertical: true)

            AnimalsRoomWeeklyCard(progress: progress)

            Spacer(minLength: 0)

            HStack(spacing: Spacing.sm + 4) {
                RoundIconButton(label: "audioToggle", systemImage: "speaker.wave.2.fill", size: 48) { }
                RoundIconButton(label: "animalRoomFavoritesButton", systemImage: "pawprint.fill", size: 48) { }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct AnimalsRoomWeeklyCard: View {
    let progress: AnimalProgressStore

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md - 2) {
            Text("animalWeeklyKicker")
                .font(FontStack.mono)
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)

            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm + 2) {
                Text(progress.animalsPlayedThisWeek, format: .number)
                    .font(.system(size: 56, weight: .regular, design: .serif))
                    .kerning(-1)
                    .foregroundStyle(palette.ink)
                Text("animalWeeklyValueUnit")
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
            }

            HStack(spacing: 6) {
                ForEach(progress.weekActivity.indices, id: \.self) { idx in
                    Capsule(style: .continuous)
                        .fill(progress.weekActivity[idx] ? palette.animals : palette.line)
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

private struct AnimalsRoomGrid: View {
    let activities: [AnimalActivityID]
    let isCompactWidth: Bool
    let onSelect: (AnimalActivityID) -> Void

    private var columnCount: Int { isCompactWidth ? 2 : 3 }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: columnCount)
    }

    private var standardTiles: [AnimalActivityID] { activities.filter { !$0.isWide } }
    private var wideTiles: [AnimalActivityID] { activities.filter(\.isWide) }

    private let tileHeight: CGFloat = 260

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(standardTiles) { activity in
                AnimalsRoomTile(activity: activity, onSelect: onSelect)
                    .frame(height: tileHeight)
            }

            // The wide Free Play tile spans two columns on the next row.
            ForEach(wideTiles) { activity in
                AnimalsRoomTile(activity: activity, onSelect: onSelect)
                    .frame(height: tileHeight)
                    .gridCellColumns(2)
            }
        }
    }
}

private struct AnimalsRoomTile: View {
    let activity: AnimalActivityID
    let onSelect: (AnimalActivityID) -> Void

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
        case .match:    AnimalMatchTileArt()
        case .sort:     AnimalSortTileArt()
        case .find:     AnimalFindTileArt()
        case .freePlay: AnimalFreePlayTileArt()
        }
    }
}

#Preview("Animal Room — warm") {
    AnimalsRoomPreviewHarness(palette: .warm)
}

#Preview("Animal Room — compact width") {
    AnimalsRoomPreviewHarness(palette: .warm)
        .environment(\.horizontalSizeClass, .compact)
}

private struct AnimalsRoomPreviewHarness: View {
    let palette: Palette
    @State private var path = NavigationPath()
    @State private var progress = AnimalProgressStore()

    var body: some View {
        NavigationStack(path: $path) {
            AnimalsRoomView(path: $path)
                .environment(\.palette, palette)
                .environment(progress)
        }
    }
}
