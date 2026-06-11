import SwiftUI

struct ProgressDots: View {
    let count: Int
    let active: Int

    @Environment(\.palette) private var palette
    @Environment(\.pace) private var pace

    var body: some View {
        let model = ProgressDotsModel(count: count, active: active)
        HStack(spacing: Spacing.sm + 2) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == model.highlightedIndex ? palette.ink : palette.line)
                    .frame(width: index == model.highlightedIndex ? 28 : 10, height: 10)
            }
        }
        .animation(pace.baseAnimation, value: active)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("progressDotsLabel \(model.stepNumber) \(count)"))
    }
}
