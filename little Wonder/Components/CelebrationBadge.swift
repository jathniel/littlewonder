import SwiftUI

/// Capsule "well done" badge shown over an activity stage on completion.
/// Mirrors the inline celebration used by the Shape activities.
struct CelebrationBadge: View {
    let text: LocalizedStringKey

    @Environment(\.palette) private var palette

    var body: some View {
        Text(text)
            .font(.system(.headline, design: .serif).italic())
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .background(palette.paperHi, in: .capsule)
            .overlay { Capsule().stroke(palette.line, lineWidth: 1) }
            .foregroundStyle(palette.ink)
            .transition(.scale.combined(with: .opacity))
    }
}
