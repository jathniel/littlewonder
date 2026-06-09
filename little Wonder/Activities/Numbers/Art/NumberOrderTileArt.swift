import SwiftUI

struct NumberOrderTileArt: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...3, id: \.self) { value in
                Text(value, format: .number)
                    .font(.system(size: 30, weight: .regular, design: .serif))
                    .foregroundStyle(palette.ink)
                    .frame(width: 40, height: 48)
                    .background(palette.sage.opacity(0.16), in: .rect(cornerRadius: 12, style: .continuous))
            }
        }
    }
}
