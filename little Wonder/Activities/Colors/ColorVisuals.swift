import SwiftUI

/// A rounded, solid colour chip — the draggable / tappable token used across the
/// Colour activities. Mirrors `NumeralTile`'s role in the Number room.
struct SwatchChip: View {
    let swatch: ColorSwatch
    var size: CGFloat = 120

    @Environment(\.palette) private var palette

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
            .fill(palette[keyPath: swatch.fill])
            .frame(width: size, height: size)
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                    .stroke(.white.opacity(0.35), lineWidth: max(1, size * 0.02))
            }
    }
}

/// A faint, outlined "drop here" frame tinted with a colour — visually distinct from
/// `SwatchChip` so it reads as a target rather than a duplicate swatch.
struct SwatchTarget: View {
    let swatch: ColorSwatch
    var size: CGFloat = 120
    var placed: Bool = false

    @Environment(\.palette) private var palette

    var body: some View {
        let color = palette[keyPath: swatch.fill]
        RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
            .fill(color.opacity(placed ? 1 : 0.16))
            .frame(width: size, height: size)
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                    .stroke(color.opacity(placed ? 0 : 0.7),
                            style: StrokeStyle(lineWidth: 2.5, dash: placed ? [] : [8, 8]))
            }
    }
}

/// A circular paint blob — used by the Mix pots and the Free Play / Paint stamps.
struct ColorBlob: View {
    let swatch: ColorSwatch
    var size: CGFloat = 96

    @Environment(\.palette) private var palette

    var body: some View {
        Circle()
            .fill(palette[keyPath: swatch.fill])
            .frame(width: size, height: size)
            .overlay {
                Circle().stroke(.white.opacity(0.3), lineWidth: max(1, size * 0.03))
            }
    }
}
