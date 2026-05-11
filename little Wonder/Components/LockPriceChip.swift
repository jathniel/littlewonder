import SwiftUI

struct LockPriceChip: View {
    let price: LocalizedStringKey

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "lock.fill")
                .font(.footnote.weight(.semibold))
            Text(price)
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(palette.ink)
        .padding(.vertical, Spacing.xs)
        .padding(.leading, Spacing.sm)
        .padding(.trailing, Spacing.sm + 2)
        .background(palette.paperHi, in: .capsule)
        .overlay { Capsule().stroke(palette.line, lineWidth: 1) }
    }
}
