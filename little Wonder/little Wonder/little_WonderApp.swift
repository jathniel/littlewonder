import SwiftUI

@main
struct little_WonderApp: App {
    @State private var themeSettings = ThemeSettings()
    @State private var profileStore = ProfileStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(themeSettings)
                .environment(profileStore)
                .themed(from: themeSettings)
        }
    }
}
