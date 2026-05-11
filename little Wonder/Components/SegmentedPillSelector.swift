import SwiftUI

struct SegmentedPillSelector<Option: Identifiable & Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> LocalizedStringKey

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(options) { option in
                Button {
                    selection = option
                } label: {
                    Text(label(option))
                        .font(.system(.subheadline, design: .rounded).bold())
                        .kerning(0.2)
                        .foregroundStyle(option == selection ? palette.paperHi : palette.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md - 4)
                        .background(
                            option == selection ? palette.ink : .clear,
                            in: .rect(cornerRadius: Radius.md - 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.xs + 2)
        .background(palette.paperHi, in: .rect(cornerRadius: Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .stroke(palette.line, lineWidth: 1.5)
        }
    }
}
