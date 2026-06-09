import SwiftUI

struct RootView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var path = NavigationPath()
    @State private var shapeProgress = ShapeProgressStore()
    @State private var numberProgress = NumberProgressStore()
    @State private var colorProgress = ColorProgressStore()

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
                case .numbers:
                    NumbersRoomView(path: $path)
                case .colors:
                    ColorsRoomView(path: $path)
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
            .navigationDestination(for: NumberActivityID.self) { activity in
                switch activity {
                case .count:    NumberCountView()
                case .match:    NumberMatchView()
                case .order:    NumberOrderView()
                case .freePlay: NumberFreePlayView()
                }
            }
            .navigationDestination(for: ColorActivityID.self) { activity in
                switch activity {
                case .match:    ColorMatchView()
                case .sort:     ColorSortView()
                case .find:     ColorFindView()
                case .mix:      ColorMixView()
                case .freePlay: ColorFreePlayView()
                }
            }
        }
        .environment(shapeProgress)
        .environment(numberProgress)
        .environment(colorProgress)
    }
}
