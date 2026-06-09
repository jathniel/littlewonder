import SwiftUI

/// A rounded tile displaying a single numeral — the draggable/tappable token used
/// across the Number activities.
struct NumeralTile: View {
    let value: Int
    let fill: Color
    var size: CGFloat = 120

    var body: some View {
        Text(value, format: .number)
            .font(.system(size: size * 0.5, weight: .regular, design: .serif))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(fill, in: .rect(cornerRadius: size * 0.18, style: .continuous))
    }
}

/// A cluster of `count` dots, arranged in rows of up to three — used to represent
/// a quantity the child matches a numeral against.
struct DotCluster: View {
    let count: Int
    let color: Color
    var dotSize: CGFloat = 22

    private var rows: [[Int]] {
        let perRow = 3
        return stride(from: 0, to: count, by: perRow).map { start in
            Array(start..<min(start + perRow, count))
        }
    }

    var body: some View {
        VStack(spacing: dotSize * 0.4) {
            ForEach(rows.enumerated(), id: \.offset) { _, row in
                HStack(spacing: dotSize * 0.4) {
                    ForEach(row, id: \.self) { _ in
                        Circle()
                            .fill(color)
                            .frame(width: dotSize, height: dotSize)
                    }
                }
            }
        }
    }
}
