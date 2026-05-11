import SwiftUI

struct ProfileSetupView: View {
    let onAdvance: () -> Void

    @Environment(\.palette) private var palette
    @Environment(ProfileStore.self) private var profile

    var body: some View {
        @Bindable var profile = profile

        ZStack {
            palette.paper.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ProfileSetupHeader()
                    .padding(.top, 96)

                ProfilePreviewCard(
                    name: profile.name,
                    age: profile.age,
                    avatarShape: profile.avatarShape,
                    avatarColor: profile.avatarColor,
                    narrationLanguage: profile.narrationLanguage,
                    handedness: profile.handedness
                )
                .padding(.top, Spacing.lg)

                ProfileFieldsStack(
                    name: $profile.name,
                    age: $profile.age,
                    avatarShape: $profile.avatarShape,
                    avatarColor: $profile.avatarColor,
                    narrationLanguage: $profile.narrationLanguage,
                    handedness: $profile.handedness
                )
                .padding(.top, Spacing.xl - 8)

                Spacer(minLength: Spacing.lg)

                ProfileSetupFooter(onAdvance: onAdvance)
            }
            .padding(.horizontal, Spacing.xxl - 8)
            .padding(.bottom, Spacing.xxl - 8)
        }
    }
}

#Preview("Profile setup — warm") {
    ProfileSetupView(onAdvance: {})
        .environment(ProfileStore(defaults: .standard))
        .environment(\.palette, .warm)
}

private struct ProfileSetupHeader: View {
    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm + 2) {
            Text("profileSetupKicker")
                .font(FontStack.mono)
                .kerning(2)
                .textCase(.uppercase)
                .foregroundStyle(palette.inkSoft)

            Text("profileSetupTitle")
                .font(.system(.largeTitle, design: .serif))
                .kerning(-1.4)
                .foregroundStyle(palette.ink)

            Text("profileSetupBlurb")
                .font(.system(.callout, design: .rounded).weight(.medium))
                .foregroundStyle(palette.inkSoft)
                .frame(maxWidth: 580, alignment: .leading)
                .padding(.top, Spacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ProfilePreviewCard: View {
    let name: String
    let age: Int
    let avatarShape: ShapeKind
    let avatarColor: AvatarColor
    let narrationLanguage: NarrationLanguage
    let handedness: Handedness

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: Spacing.lg - 2) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.xl - 8, style: .continuous)
                    .fill(palette.sand)
                RoundedRectangle(cornerRadius: Radius.xl - 8, style: .continuous)
                    .stroke(palette.line, lineWidth: 1)
                PrimitiveShape(kind: avatarShape, size: 64, fill: avatarColor.color(in: palette))
            }
            .frame(width: 96, height: 96)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("profilePreviewKicker")
                    .font(FontStack.mono)
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)

                Text(greeting)
                    .font(.system(.title, design: .serif))
                    .kerning(-0.8)
                    .foregroundStyle(palette.ink)
                    .lineLimit(1)

                Text(meta)
                    .font(.system(.footnote, design: .rounded).weight(.medium))
                    .foregroundStyle(palette.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.md + 6)
        .background(palette.paperHi, in: .rect(cornerRadius: Radius.lg + 4))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.lg + 4, style: .continuous)
                .stroke(palette.line, lineWidth: 1.5)
        }
    }

    private var greeting: String {
        let display = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let friendly = display.isEmpty ? String(localized: "profileDefaultName") : display
        return String(localized: "profilePreviewGreeting \(friendly)")
    }

    private var meta: String {
        String(localized: "profilePreviewMeta \(age) \(narrationLanguage.localized) \(handedness.localized)")
    }
}

private struct ProfileFieldsStack: View {
    @Binding var name: String
    @Binding var age: Int
    @Binding var avatarShape: ShapeKind
    @Binding var avatarColor: AvatarColor
    @Binding var narrationLanguage: NarrationLanguage
    @Binding var handedness: Handedness

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg - 2) {
            ProfileFieldNameRow(name: $name)
            ProfileFieldAgeRow(age: $age)
            ProfileFieldAvatarRow(avatarShape: $avatarShape, avatarColor: $avatarColor)
            ProfileFieldOptionsRow(
                narrationLanguage: $narrationLanguage,
                handedness: $handedness
            )
        }
    }
}

private struct ProfileFieldNameRow: View {
    @Binding var name: String

    @Environment(\.palette) private var palette
    @FocusState private var focused: Bool

    var body: some View {
        ProfileField(label: "profileFieldName") {
            TextField(text: $name, prompt: Text("profileFieldNamePlaceholder")) {
                Text("profileFieldName")
            }
            .focused($focused)
            .textInputAutocapitalization(.words)
            .submitLabel(.done)
            .font(.system(.title2, design: .serif))
            .kerning(-0.3)
            .foregroundStyle(palette.ink)
            .padding(.horizontal, Spacing.md + 2)
            .padding(.vertical, Spacing.md - 2)
            .background(palette.paperHi, in: .rect(cornerRadius: Radius.md + 2))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md + 2, style: .continuous)
                    .stroke(palette.line, lineWidth: 1.5)
            }
        }
    }
}

private struct ProfileFieldAgeRow: View {
    @Binding var age: Int

    @Environment(\.palette) private var palette

    private let ages: [Int] = [2, 3, 4, 5, 6]

    var body: some View {
        ProfileField(label: "profileFieldAge") {
            HStack(spacing: Spacing.sm + 2) {
                ForEach(ages, id: \.self) { value in
                    Button {
                        age = value
                    } label: {
                        Text(value, format: .number)
                            .font(.system(.title, design: .serif))
                            .foregroundStyle(value == age ? palette.paperHi : palette.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(
                                value == age ? palette.ink : palette.paperHi,
                                in: .rect(cornerRadius: Radius.md + 2)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: Radius.md + 2, style: .continuous)
                                    .stroke(value == age ? palette.ink : palette.line, lineWidth: 1.5)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct ProfileFieldAvatarRow: View {
    @Binding var avatarShape: ShapeKind
    @Binding var avatarColor: AvatarColor

    @Environment(\.palette) private var palette

    private let shapes: [ShapeKind] = [.circle, .square, .triangle, .hexagon, .star]

    var body: some View {
        ProfileField(label: "profileFieldAvatar", hint: "profileFieldAvatarHint") {
            HStack(spacing: Spacing.md + 2) {
                shapesCard
                colorsCard
            }
        }
    }

    private var shapesCard: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(shapes, id: \.self) { shape in
                Button {
                    avatarShape = shape
                } label: {
                    PrimitiveShape(kind: shape, size: 28, fill: palette.ink)
                        .frame(width: 48, height: 48)
                        .background(
                            avatarShape == shape ? palette.sand : .clear,
                            in: .rect(cornerRadius: Radius.md - 2)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: Radius.md - 2, style: .continuous)
                                .stroke(avatarShape == shape ? palette.ink : .clear, lineWidth: 1.5)
                        }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(Spacing.sm + 4)
        .background(palette.paperHi, in: .rect(cornerRadius: Radius.md + 2))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.md + 2, style: .continuous)
                .stroke(palette.line, lineWidth: 1.5)
        }
    }

    private var colorsCard: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(AvatarColor.allCases) { color in
                Button {
                    avatarColor = color
                } label: {
                    Circle()
                        .fill(color.color(in: palette))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Circle()
                                .stroke(avatarColor == color ? palette.ink : .clear, lineWidth: 2.5)
                                .padding(-2)
                        }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(Spacing.sm + 4)
        .background(palette.paperHi, in: .rect(cornerRadius: Radius.md + 2))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.md + 2, style: .continuous)
                .stroke(palette.line, lineWidth: 1.5)
        }
    }
}

private struct ProfileFieldOptionsRow: View {
    @Binding var narrationLanguage: NarrationLanguage
    @Binding var handedness: Handedness

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            ProfileField(label: "profileFieldNarration") {
                SegmentedPillSelector(
                    options: NarrationLanguage.allCases,
                    selection: $narrationLanguage,
                    label: { $0.displayKey }
                )
            }
            .frame(maxWidth: .infinity)

            ProfileField(label: "profileFieldHandedness") {
                SegmentedPillSelector(
                    options: Handedness.allCases,
                    selection: $handedness,
                    label: { $0.displayKey }
                )
            }
            .frame(maxWidth: 220)
        }
    }
}

private struct ProfileSetupFooter: View {
    let onAdvance: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            Text("profileSetupFooterNote")
                .font(.footnote.weight(.medium))
                .foregroundStyle(palette.inkSoft)
                .frame(maxWidth: .infinity, alignment: .leading)

            ProgressDots(count: 3, active: 1)

            PillButton(title: "profileSetupSave", kind: .primary, size: .lg, action: onAdvance)
        }
    }
}

