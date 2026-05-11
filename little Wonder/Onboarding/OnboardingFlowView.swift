import SwiftUI

struct OnboardingFlowView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var step: OnboardingStep = .welcome
    @Environment(\.pace) private var pace

    var body: some View {
        ZStack {
            switch step {
            case .welcome:
                WelcomeView { advance(to: .profile) }
                    .transition(.opacity)
            case .profile:
                ProfileSetupView { advance(to: .firstTouch) }
                    .transition(.opacity)
            case .firstTouch:
                FirstTouchView { finish() }
                    .transition(.opacity)
            }
        }
        .animation(pace.baseAnimation, value: step)
    }

    private func advance(to next: OnboardingStep) {
        step = next
    }

    private func finish() {
        hasOnboarded = true
    }
}
