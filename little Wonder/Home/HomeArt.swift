import SwiftUI

struct HomeArt: View {
    let topic: TopicID

    var body: some View {
        Group {
            switch topic {
            case .shapes:   HomeArtShapes()
            case .numbers:  HomeArtNumbers()
            case .animals:  HomeArtAnimals()
            case .colors:   HomeArtColors()
            case .letters:  HomeArtLetters()
            case .feelings: HomeArtFeelings()
            }
        }
        .frame(width: 220, height: 220)
    }
}

private struct HomeArtShapes: View {
    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            PrimitiveShape(kind: .circle, size: 110, fill: palette.terracotta)
                .offset(x: -50, y: 16)
            PrimitiveShape(kind: .square, size: 80, fill: palette.oak)
                .offset(x: 56, y: -56)
            PrimitiveShape(kind: .triangle, size: 92, fill: palette.sage)
                .offset(x: 40, y: 46)
        }
    }
}

private struct HomeArtNumbers: View {
    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            Text(verbatim: "3")
                .font(.system(size: 180, weight: .regular, design: .serif))
                .kerning(-8)
                .foregroundStyle(palette.numbers)
                .frame(width: 220, height: 220)

            VStack(spacing: 10) {
                Circle().fill(palette.numbers).frame(width: 22, height: 22)
                Circle().fill(palette.numbers).frame(width: 22, height: 22)
                Circle().fill(palette.numbers).frame(width: 22, height: 22)
            }
            .offset(x: 70, y: -50)
        }
    }
}

private struct HomeArtAnimals: View {
    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            PrimitiveShape(kind: .oval, size: 150, fill: palette.animals)
                .offset(x: 0, y: 30)
            PrimitiveShape(kind: .circle, size: 86, fill: palette.animals)
                .offset(x: 0, y: -28)
            PrimitiveShape(kind: .triangle, size: 36, fill: palette.animals)
                .offset(x: -30, y: -68)
                .rotationEffect(.degrees(-20))
            PrimitiveShape(kind: .triangle, size: 36, fill: palette.animals)
                .offset(x: 30, y: -68)
                .rotationEffect(.degrees(20))
            Circle().fill(palette.ink).frame(width: 10, height: 10).offset(x: -16, y: -22)
            Circle().fill(palette.ink).frame(width: 10, height: 10).offset(x: 16, y: -22)
        }
    }
}

private struct HomeArtColors: View {
    @Environment(\.palette) private var palette

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            Circle().fill(palette.terracotta).frame(width: 90, height: 90)
            Circle().fill(palette.sage).frame(width: 90, height: 90)
            Circle().fill(palette.mustard).frame(width: 90, height: 90)
            Circle().fill(palette.sky).frame(width: 90, height: 90)
        }
        .frame(width: 200)
    }
}

private struct HomeArtLetters: View {
    @Environment(\.palette) private var palette

    var body: some View {
        Text(verbatim: "Aa")
            .font(.system(size: 180, weight: .regular, design: .serif))
            .italic()
            .kerning(-10)
            .foregroundStyle(palette.plum)
    }
}

private struct HomeArtFeelings: View {
    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            PrimitiveShape(kind: .circle, size: 150, fill: palette.berry)
            Circle().fill(palette.ink).frame(width: 14, height: 14).offset(x: -22, y: -10)
            Circle().fill(palette.ink).frame(width: 14, height: 14).offset(x: 22, y: -10)
            Capsule()
                .stroke(palette.ink, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 50, height: 8)
                .offset(y: 30)
        }
    }
}
