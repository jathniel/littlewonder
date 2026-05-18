import SwiftUI

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 40
    static let xxl: CGFloat = 64
}

enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 22
    static let xl: CGFloat = 36
}

enum LEShadow {
    case sm
    case md
    case lg
}

extension View {
    func leShadow(_ kind: LEShadow, ink: Color) -> some View {
        modifier(LEShadowModifier(kind: kind, ink: ink))
    }
}

private struct LEShadowModifier: ViewModifier {
    let kind: LEShadow
    let ink: Color

    func body(content: Content) -> some View {
        switch kind {
        case .sm:
            content
                .shadow(color: ink.opacity(0.04), radius: 0, y: 1)
                .shadow(color: ink.opacity(0.06), radius: 6, y: 2)
        case .md:
            content
                .shadow(color: ink.opacity(0.06), radius: 0, y: 1)
                .shadow(color: ink.opacity(0.08), radius: 22, y: 8)
        case .lg:
            content
                .shadow(color: ink.opacity(0.06), radius: 0, y: 1)
                .shadow(color: ink.opacity(0.10), radius: 50, y: 22)
        }
    }
}
