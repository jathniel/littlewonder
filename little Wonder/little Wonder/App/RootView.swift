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
                switch topic {
                case .shapes:
                    ShapesRoomView(path: $path)
                default:
                    TopicPlaceholderView(topic: topic)
                }
            }
            .navigationDestination(for: ShapeActivityID.self) { activity in
                switch activity {
                case .match:    ShapeMatchView()
                case .sort:     ShapeSortView()
                case .trace:    ShapeTraceView()
                case .build:    ShapeBuildView()
                case .freePlay: ShapeFreePlayView()
                }
            }
        }
    }
}
