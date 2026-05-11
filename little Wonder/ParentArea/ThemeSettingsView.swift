import SwiftUI

struct ThemeSettingsView: View {
    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace
    @Environment(ThemeSettings.self) private var themeSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = themeSettings

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    PaletteSection(selection: $settings.paletteMode)
                    PaceSection(selection: $settings.paceMode)
                }
                .padding(Spacing.lg)
            }
            .background(palette.paper)
            .navigationTitle(Text("themeSettingsTitle"))
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("themeSettingsDone") { dismiss() }
                }
            }
        }
        .animation(pace.baseAnimation, value: settings.paletteMode)
        .animation(pace.baseAnimation, value: settings.paceMode)
    }
}

private struct PaletteSection: View {
    @Binding var selection: PaletteMode
    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "themeSettingsPaletteHeader")
            VStack(spacing: Spacing.sm) {
                ForEach(PaletteMode.allCases) { mode in
                    PaletteCard(mode: mode, isSelected: mode == selection) {
                        selection = mode
                    }
                }
            }
        }
    }
}

private struct PaletteCard: View {
    let mode: PaletteMode
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                SwatchRow(palette: mode.palette)
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(label)
                        .font(FontStack.heading)
                        .foregroundStyle(palette.ink)
                    Text(blurb)
                        .font(FontStack.body)
                        .foregroundStyle(palette.inkSoft)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(palette.ink)
                        .font(.title3)
                }
            }
            .padding(Spacing.md)
            .background(palette.paperHi, in: .rect(cornerRadius: Radius.lg))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .stroke(isSelected ? palette.ink : palette.line, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var label: LocalizedStringKey {
        switch mode {
        case .warm: "paletteWarm"
        case .cool: "paletteCool"
        case .neutral: "paletteNeutral"
        }
    }

    private var blurb: LocalizedStringKey {
        switch mode {
        case .warm: "paletteWarmBlurb"
        case .cool: "paletteCoolBlurb"
        case .neutral: "paletteNeutralBlurb"
        }
    }
}

private struct SwatchRow: View {
    let palette: Palette

    var body: some View {
        HStack(spacing: -8) {
            SwatchDot(color: palette.terracotta)
            SwatchDot(color: palette.sage)
            SwatchDot(color: palette.sky)
            SwatchDot(color: palette.mustard)
        }
        .frame(width: 96, height: 32)
    }
}

private struct SwatchDot: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 32, height: 32)
            .overlay {
                Circle().stroke(Color.white.opacity(0.6), lineWidth: 1.5)
            }
    }
}

private struct PaceSection: View {
    @Binding var selection: PaceMode
    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "themeSettingsPaceHeader")
            VStack(spacing: Spacing.sm) {
                ForEach(PaceMode.allCases) { mode in
                    PaceCard(mode: mode, isSelected: mode == selection) {
                        selection = mode
                    }
                }
            }
        }
    }
}

private struct PaceCard: View {
    let mode: PaceMode
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(palette.ink)
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(label)
                        .font(FontStack.heading)
                        .foregroundStyle(palette.ink)
                    Text(blurb)
                        .font(FontStack.body)
                        .foregroundStyle(palette.inkSoft)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(palette.ink)
                        .font(.title3)
                }
            }
            .padding(Spacing.md)
            .background(palette.paperHi, in: .rect(cornerRadius: Radius.lg))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .stroke(isSelected ? palette.ink : palette.line, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var icon: String {
        switch mode {
        case .slow: "tortoise.fill"
        case .playful: "hare.fill"
        }
    }

    private var label: LocalizedStringKey {
        switch mode {
        case .slow: "paceSlow"
        case .playful: "pacePlayful"
        }
    }

    private var blurb: LocalizedStringKey {
        switch mode {
        case .slow: "paceSlowBlurb"
        case .playful: "pacePlayfulBlurb"
        }
    }
}

private struct SectionHeader: View {
    let title: LocalizedStringKey
    @Environment(\.palette) private var palette

    var body: some View {
        Text(title)
            .font(FontStack.label)
            .kerning(1.2)
            .foregroundStyle(palette.inkSoft)
    }
}

#Preview {
    ThemeSettingsView()
        .environment(ThemeSettings())
        .themed(from: ThemeSettings())
}
