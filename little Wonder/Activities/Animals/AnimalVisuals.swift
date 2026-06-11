import SwiftUI

/// A rounded tile drawing an animal — the draggable / tappable token used across the
/// Animal activities. Mirrors `SwatchChip`'s role in the Colour room.
struct AnimalToken: View {
    let animal: Animal
    var size: CGFloat = 120

    @Environment(\.palette) private var palette

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
            .fill(palette.paperHi)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: animal.symbol)
                    .font(.system(size: size * 0.5))
                    .foregroundStyle(palette[keyPath: animal.tint])
            }
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                    .stroke(palette.line, lineWidth: max(1, size * 0.02))
            }
    }
}

/// A faint, outlined "drop here" frame holding a darkened silhouette of an animal —
/// visually distinct from `AnimalToken` so it reads as a shadow to match, not a duplicate.
/// Mirrors `SwatchTarget`.
struct AnimalShadowTarget: View {
    let animal: Animal
    var size: CGFloat = 120
    var placed: Bool = false

    @Environment(\.palette) private var palette

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
            .fill(palette.ink.opacity(placed ? 0 : 0.05))
            .frame(width: size, height: size)
            .overlay {
                if placed {
                    AnimalToken(animal: animal, size: size)
                } else {
                    Image(systemName: animal.symbol)
                        .font(.system(size: size * 0.5))
                        .foregroundStyle(palette.ink.opacity(0.32))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                    .stroke(palette.ink.opacity(placed ? 0 : 0.3),
                            style: StrokeStyle(lineWidth: 2.5, dash: placed ? [] : [8, 8]))
            }
    }
}

/// A compact animal icon used inside habitat bins and stamp pieces. Mirrors `ColorBlob`.
struct AnimalGlyph: View {
    let animal: Animal
    var size: CGFloat = 96

    @Environment(\.palette) private var palette

    var body: some View {
        Image(systemName: animal.symbol)
            .font(.system(size: size * 0.62))
            .foregroundStyle(palette[keyPath: animal.tint])
            .frame(width: size, height: size)
    }
}
