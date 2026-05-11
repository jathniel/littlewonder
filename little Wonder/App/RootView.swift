import SwiftUI

struct RootView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if hasOnboarded {
                    HomeView(path: $path)
                } else {
                    OnboardingFlowView()
                }
            }
            .navigationDestination(for: TopicID.self) { topic in
                TopicPlaceholderView(topic: topic)
            }
        }
    }
}
