import SwiftUI

@main
struct little_WonderApp: App {
    @State private var themeSettings = ThemeSettings()
    @State private var profileStore: ProfileStore
    @State private var narrationService: NarrationService

    init() {
        let profile = ProfileStore()
        _profileStore = State(initialValue: profile)
        _narrationService = State(initialValue: NarrationService(profile: profile))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(themeSettings)
                .environment(profileStore)
                .environment(narrationService)
                .themed(from: themeSettings)
        }
    }
}
