import SwiftUI

struct RoundIconButton: View {
    let label: LocalizedStringKey
    let systemImage: String
    var size: CGFloat = 56
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3.weight(.medium))
                .foregroundStyle(palette.ink)
                .frame(width: size, height: size)
                .background(palette.paperHi, in: .circle)
                .overlay {
                    Circle().stroke(palette.line, lineWidth: 1.5)
                }
                .leShadow(.sm, ink: palette.ink)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}
