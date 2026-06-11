import CoreGraphics
import Testing
@testable import little_Wonder

@MainActor
struct ShapeTraceViewModelTests {
    private let rect = CGRect(x: 0, y: 0, width: 200, height: 200)

    @Test("Initial state — first roster shape active, zero dots filled")
    func initialState() {
        let viewModel = ShapeTraceViewModel(shapes: [.circle, .square, .triangle, .star])
        #expect(viewModel.activeShape == .circle)
        #expect(viewModel.activeIndex == 0)
        #expect(viewModel.filled == 0)
    }

    @Test("Touching the next dot advances filled")
    func progressAdvances() {
        // Pinned roster and a radius smaller than half the circle's dot spacing
        // (~34.9pt here) so each touch fills exactly one dot.
        let viewModel = ShapeTraceViewModel(shapes: [.circle, .square, .triangle, .star])
        let dots = viewModel.dots(in: rect)
        viewModel.progress(touch: dots[0], dots: dots, radius: 17)
        #expect(viewModel.filled == 1)
        viewModel.progress(touch: dots[1], dots: dots, radius: 17)
        #expect(viewModel.filled == 2)
    }

    @Test("Touching an off-path point doesn't advance")
    func progressIgnoresOffPath() {
        let viewModel = ShapeTraceViewModel()
        let dots = viewModel.dots(in: rect)
        viewModel.progress(touch: CGPoint(x: -500, y: -500), dots: dots)
        #expect(viewModel.filled == 0)
    }

    @Test("Completing all dots advances shape and resets filled")
    func advanceShape() {
        let viewModel = ShapeTraceViewModel()
        let dots = viewModel.dots(in: rect)
        for dot in dots {
            viewModel.progress(touch: dot, dots: dots)
        }
        #expect(viewModel.filled == dots.count)
        viewModel.advanceShape()
        #expect(viewModel.activeIndex == 1)
        #expect(viewModel.filled == 0)
    }

    @Test("Selecting a shape resets fill counter")
    func selectShape() {
        // Pinned roster: selecting a shape only works when it is in the roster.
        let viewModel = ShapeTraceViewModel(shapes: [.circle, .square, .triangle, .star])
        let dots = viewModel.dots(in: rect)
        viewModel.progress(touch: dots[0], dots: dots)
        viewModel.selectShape(.triangle)
        #expect(viewModel.activeShape == .triangle)
        #expect(viewModel.filled == 0)
    }
}
