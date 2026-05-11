import SwiftUI

enum PillButtonKind {
    case primary
    case secondary
    case quiet
}

enum PillButtonSize {
    case sm
    case md
    case lg

    var textStyle: Font.TextStyle {
        switch self {
        case .sm: .subheadline
        case .md: .body
        case .lg: .title3
        }
    }

    var paddingH: CGFloat {
        switch self {
        case .sm: 18
        case .md: 26
        case .lg: 34
        }
    }

    var paddingV: CGFloat {
        switch self {
        case .sm: 10
        case .md: 14
        case .lg: 18
        }
    }
}

struct PillButton: View {
    let title: LocalizedStringKey
    var kind: PillButtonKind = .primary
    var size: PillButtonSize = .md
    var isFullWidth: Bool = false
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size.textStyle, design: .rounded).bold())
                .kerning(0.2)
                .padding(.horizontal, size.paddingH)
                .padding(.vertical, size.paddingV)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .foregroundStyle(foreground)
                .background(background, in: .capsule)
                .overlay {
                    if kind == .secondary {
                        Capsule().stroke(palette.ink, lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var background: Color {
        switch kind {
        case .primary: palette.ink
        case .secondary: .clear
        case .quiet: palette.sand
        }
    }

    private var foreground: Color {
        switch kind {
        case .primary: palette.paperHi
        case .secondary, .quiet: palette.ink
        }
    }
}
