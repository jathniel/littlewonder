import SwiftUI

struct ScreenSurface<Content: View>: View {
    var padding: CGFloat = Spacing.xxl
    @ViewBuilder var content: () -> Content

    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            palette.paper
                .ignoresSafeArea()
            content()
                .padding(padding)
                .foregroundStyle(palette.ink)
        }
    }
}
