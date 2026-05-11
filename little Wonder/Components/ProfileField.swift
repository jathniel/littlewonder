import SwiftUI

struct ProfileField<Content: View>: View {
    let label: LocalizedStringKey
    var hint: LocalizedStringKey? = nil
    @ViewBuilder var content: () -> Content

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(FontStack.mono)
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.inkSoft)
                Spacer()
                if let hint {
                    Text(hint)
                        .font(.system(.footnote, design: .serif).italic())
                        .foregroundStyle(palette.inkSoft)
                }
            }
            content()
        }
    }
}
