import SwiftUI

struct ActivityTile<Art: View>: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let accent: KeyPath<Palette, Color>
    var isWide: Bool = false
    @ViewBuilder var art: () -> Art
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            ZStack {
                palette.paperHi

                if isWide {
                    HStack(spacing: 0) {
                        ZStack {
                            palette[keyPath: accent].opacity(0.13)
                            art()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(alignment: .trailing) {
                            Rectangle().fill(palette.line).frame(width: 1)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.system(size: 24, weight: .medium, design: .serif))
                                .foregroundStyle(palette.ink)
                            Text(subtitle)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(palette.inkSoft)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 22)
                    }
                } else {
                    VStack(spacing: 0) {
                        ZStack {
                            palette[keyPath: accent].opacity(0.13)
                            art()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(palette.line).frame(height: 1)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.system(size: 20, weight: .medium, design: .serif))
                                .foregroundStyle(palette.ink)
                            Text(subtitle)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(palette.inkSoft)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(.rect(cornerRadius: 26))
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(palette.line, lineWidth: 1.5)
            }
            .leShadow(.md, ink: palette.ink)
        }
        .buttonStyle(.plain)
    }
}
