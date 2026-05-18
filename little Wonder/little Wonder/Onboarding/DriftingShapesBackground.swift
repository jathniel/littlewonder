import SwiftUI

struct DriftingShapesBackground: View {
    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isDrifting = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                DriftingShape(
                    shape: .circle,
                    size: 260,
                    color: palette.terracotta,
                    opacity: 0.85,
                    origin: CGPoint(x: -60, y: 80),
                    translation: CGSize(width: 20, height: 14),
                    rotation: 8,
                    multiplier: 8.0,
                    isDrifting: isDrifting
                )
                DriftingShape(
                    shape: .square,
                    size: 180,
                    color: palette.oak,
                    opacity: 0.9,
                    origin: CGPoint(x: geo.size.width - 140, y: 220),
                    translation: CGSize(width: -16, height: 22),
                    rotation: -6,
                    multiplier: 9.0,
                    isDrifting: isDrifting
                )
                DriftingShape(
                    shape: .triangle,
                    size: 150,
                    color: palette.sage,
                    opacity: 1.0,
                    origin: CGPoint(x: 200, y: 380),
                    translation: CGSize(width: 14, height: -10),
                    rotation: 4,
                    multiplier: 10.0,
                    isDrifting: isDrifting
                )
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            isDrifting = !reduceMotion
        }
    }
}

private struct DriftingShape: View {
    let shape: ShapeKind
    let size: CGFloat
    let color: Color
    let opacity: Double
    let origin: CGPoint
    let translation: CGSize
    let rotation: Double
    let multiplier: Double
    let isDrifting: Bool

    @Environment(\.pace) private var pace

    var body: some View {
        let duration = pace.long * multiplier
        PrimitiveShape(kind: shape, size: size, fill: color)
            .opacity(opacity)
            .rotationEffect(.degrees(isDrifting ? rotation : 0))
            .offset(
                x: origin.x + (isDrifting ? translation.width : 0),
                y: origin.y + (isDrifting ? translation.height : 0)
            )
            .animation(
                pace.animation(duration).repeatForever(autoreverses: true),
                value: isDrifting
            )
    }
}
