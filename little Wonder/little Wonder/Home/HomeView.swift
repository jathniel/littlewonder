import SwiftUI

struct HomeView: View {
    @Binding var path: NavigationPath

    @Environment(\.palette) private var palette
    @Environment(ProfileStore.self) private var profile
    @State private var isSettingsPresented = false

    private let unlocked: [TopicID] = [.shapes, .numbers, .animals, .colors]
    private let locked: [LockedTopic] = [
        LockedTopic(topic: .letters, kicker: "lockedKickerComingNext", price: "lockedPriceLetters", blurb: "lockedBlurbLetters"),
        LockedTopic(topic: .feelings, kicker: "lockedKickerOnTheWay", price: "lockedPriceFeelings", blurb: "lockedBlurbFeelings"),
    ]

    var body: some View {
        ZStack {
            palette.paper.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        HomeHeader(name: profile.displayName)
                        HomeUnlockedGrid(topics: unlocked, path: $path)
                        HomeLockedSection(topics: locked) {
                            isSettingsPresented = true
                        }
                    }
                    .padding(.horizontal, Spacing.xxl - 8)
                    .padding(.top, 80)
                    .padding(.bottom, Spacing.lg)
                }
                .scrollIndicators(.hidden)

                HomeFooter(isSettingsPresented: $isSettingsPresented)
                    .padding(.horizontal, Spacing.xxl - 8)
                    .padding(.vertical, Spacing.md)
                    .background(palette.paper)
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            ThemeSettingsView()
        }
    }
}

private struct LockedTopic: Identifiable {
    let topic: TopicID
    let kicker: LocalizedStringKey
    let price: LocalizedStringKey
    let blurb: LocalizedStringKey

    var id: TopicID { topic }
}

private extension TopicID {
    var labelKey: LocalizedStringKey {
        switch self {
        case .shapes:   "topicShapes"
        case .numbers:  "topicNumbers"
        case .animals:  "topicAnimals"
        case .colors:   "topicColors"
        case .letters:  "topicLetters"
        case .feelings: "topicFeelings"
        }
    }
}

private struct HomeUnlockedGrid: View {
    let topics: [TopicID]
    @Binding var path: NavigationPath

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.lg - 4),
            GridItem(.flexible(), spacing: Spacing.lg - 4),
        ], spacing: Spacing.lg - 4) {
            ForEach(topics.enumerated(), id: \.element.id) { index, topic in
                DoorTile(
                    kicker: kicker(for: index),
                    label: topic.labelKey,
                    accent: topic.accent,
                    size: 300
                ) {
                    HomeArt(topic: topic)
                } action: {
                    path.append(topic)
                }
            }
        }
    }

    private func kicker(for index: Int) -> LocalizedStringKey {
        switch index {
        case 0: "topicKicker01"
        case 1: "topicKicker02"
        case 2: "topicKicker03"
        default: "topicKicker04"
        }
    }
}

private struct HomeLockedSection: View {
    let topics: [LockedTopic]
    let onLockedTap: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md - 4) {
            HStack(alignment: .firstTextBaseline) {
                Text("homeLockedHeader")
                    .font(FontStack.mono)
                    .kerning(2)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)
                Spacer()
                Text("homeLockedHint")
                    .font(.system(.footnote, design: .serif).italic())
                    .foregroundStyle(palette.inkSoft)
            }

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.md),
                GridItem(.flexible(), spacing: Spacing.md),
            ], spacing: Spacing.md) {
                ForEach(topics) { item in
                    LockedDoorTile(
                        kicker: item.kicker,
                        label: item.topic.labelKey,
                        price: item.price,
                        accent: item.topic.accent
                    ) {
                        HomeArt(topic: item.topic)
                    } action: {
                        onLockedTap()
                    }
                }
            }
        }
    }
}

private struct HomeHeader: View {
    let name: String

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: Spacing.xs + 2) {
                Text(dateKicker)
                    .font(FontStack.mono)
                    .kerning(2)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)

                Text(greeting)
                    .font(.system(size: 56, weight: .regular, design: .serif))
                    .kerning(-1.6)
                    .foregroundStyle(palette.ink)
            }

            Spacer()

            RoundIconButton(
                label: "homeFavoritesButton",
                systemImage: "star.fill",
                size: 56
            ) { }
        }
    }

    private var dateKicker: String {
        Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased()
    }

    private var greeting: String {
        String(localized: "homeGreeting \(name)")
    }
}

#Preview("Home — warm") {
    HomeViewPreviewHarness(palette: .warm)
}

#Preview("Home — cool") {
    HomeViewPreviewHarness(palette: .cool)
}

private struct HomeViewPreviewHarness: View {
    let palette: Palette
    @State private var path = NavigationPath()
    @State private var profile: ProfileStore = {
        let store = ProfileStore(defaults: .standard)
        store.name = "Mira"
        store.age = 4
        return store
    }()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .environment(profile)
                .environment(\.palette, palette)
        }
    }
}

private struct HomeFooter: View {
    @Binding var isSettingsPresented: Bool

    @Environment(\.palette) private var palette
    @Environment(ProfileStore.self) private var profile

    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: Spacing.sm + 4) {
                RoundIconButton(
                    label: "audioToggle",
                    systemImage: profile.isNarrationOn ? "speaker.wave.2.fill" : "speaker.slash.fill",
                    size: 48
                ) {
                    profile.isNarrationOn.toggle()
                }
                Text(profile.isNarrationOn ? "homeNarrationOn" : "homeNarrationOff")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(palette.inkSoft)
            }

            Spacer()

            PillButton(title: "forGrownUps", kind: .quiet, size: .sm) {
                isSettingsPresented = true
            }
        }
    }
}
