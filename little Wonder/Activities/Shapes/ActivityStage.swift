import SwiftUI

/// Reusable chrome for every shape activity board: toolbar + framed stage card + header.
struct ActivityStage<Content: View>: View {
    let kicker: LocalizedStringKey
    let title: LocalizedStringKey
    let prompt: LocalizedStringKey?
    let progress: ProgressDots
    let onClose: () -> Void
    let onReset: () -> Void
    let onSpeak: () -> Void
    @ViewBuilder let content: Content

    @Environment(\.palette) private var palette
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 44

    var body: some View {
        ZStack(alignment: .top) {
            palette.paper.ignoresSafeArea()

            stageCard
                .padding(.horizontal, 28)
                .padding(.top, 120)
                .padding(.bottom, 28)

            toolbar
                .padding(.horizontal, 28)
                .padding(.top, 56)
        }
        .navigationBarBackButtonHidden()
    }

    private var toolbar: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            RoundIconButton(label: "topicPlaceholderBack", systemImage: "chevron.left", size: 52, action: onClose)
            Spacer()
            progress
            Spacer()
            HStack(spacing: Spacing.sm + 4) {
                RoundIconButton(label: "shapeStageReset", systemImage: "arrow.counterclockwise", size: 48, action: onReset)
                RoundIconButton(label: "audioToggle", systemImage: "speaker.wave.2.fill", size: 48, action: onSpeak)
            }
        }
    }

    private var stageCard: some View {
        VStack(alignment: .leading, spacing: 28) {
            header
            content
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(palette.paperHi, in: .rect(cornerRadius: 36, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(palette.line, lineWidth: 1.5)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(kicker)
                    .font(FontStack.mono)
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)
                Text(title)
                    .font(.system(size: titleSize, weight: .regular, design: .serif))
                    .kerning(-1)
                    .foregroundStyle(palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            if let prompt {
                Text(prompt)
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 280, alignment: .trailing)
                    .lineSpacing(4)
            }
        }
    }
}
