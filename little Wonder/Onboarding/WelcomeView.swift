import SwiftUI

struct WelcomeView: View {
    let onAdvance: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            palette.paper.ignoresSafeArea()
            DriftingShapesBackground()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text("Little Wonder")
                    .font(FontStack.mono)
                    .kerning(2)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)
                    .padding(.bottom, Spacing.md + 2)

                Text(.init("welcomeHeadline"))
                    .font(.system(.largeTitle, design: .serif))
                    .kerning(-2.5)
                    .lineSpacing(-4)
                    .foregroundStyle(palette.ink)
                    .frame(maxWidth: 560, alignment: .leading)

                Text(.init("welcomeBlurb"))
                    .font(.system(.title3, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
                    .lineSpacing(4)
                    .padding(.top, Spacing.lg - 2)
                    .frame(maxWidth: 480, alignment: .leading)

                HStack(spacing: Spacing.md - 2) {
                    PillButton(title: "openTheDoor", kind: .primary, size: .lg, action: onAdvance)
                    PillButton(title: "restorePurchase", kind: .quiet, size: .md) { }
                }
                .padding(.top, Spacing.xl - 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.xxl)
            .padding(.bottom, Spacing.xxl + Spacing.md)
        }
    }
}
