import SwiftUI

extension EnvironmentValues {
    @Entry var palette: Palette = .warm
    @Entry var pace: Pace = .slow
}

extension View {
    func themed(from settings: ThemeSettings) -> some View {
        self
            .environment(\.palette, settings.paletteMode.palette)
            .environment(\.pace, settings.paceMode.pace)
    }
}
