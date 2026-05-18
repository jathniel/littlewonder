import SwiftUI

struct TopicPlaceholderView: View {
    let topic: TopicID

    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            palette.paper.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack(spacing: Spacing.sm + 4) {
                    RoundIconButton(
                        label: "topicPlaceholderBack",
                        systemImage: "chevron.left",
                        size: 48
                    ) {
                        dismiss()
                    }
                    TopicBadge(label: topicLabel, accent: topic.accent)
                }

                Text(topicTitle)
                    .font(.system(size: 60, weight: .regular, design: .serif))
                    .kerning(-1.8)
                    .foregroundStyle(palette.ink)

                Text("topicPlaceholderBlurb")
                    .font(.system(.title3, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
                    .frame(maxWidth: 520, alignment: .leading)
            }
            .padding(.horizontal, Spacing.xxl - 8)
            .padding(.top, 80)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .navigationBarBackButtonHidden()
    }

    private var topicLabel: LocalizedStringKey {
        switch topic {
        case .shapes:   "topicShapes"
        case .numbers:  "topicNumbers"
        case .animals:  "topicAnimals"
        case .colors:   "topicColors"
        case .letters:  "topicLetters"
        case .feelings: "topicFeelings"
        }
    }

    private var topicTitle: LocalizedStringKey {
        switch topic {
        case .shapes:   "topicTitleShapes"
        case .numbers:  "topicTitleNumbers"
        case .animals:  "topicTitleAnimals"
        case .colors:   "topicTitleColors"
        case .letters:  "topicTitleLetters"
        case .feelings: "topicTitleFeelings"
        }
    }
}
