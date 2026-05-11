import SwiftUI

struct Palette: Equatable {
    let paper: Color
    let paperHi: Color
    let sand: Color
    let ink: Color
    let inkSoft: Color
    let line: Color
    let terracotta: Color
    let oak: Color
    let mustard: Color
    let sage: Color
    let sky: Color
    let berry: Color
    let plum: Color
    let shapes: Color
    let numbers: Color
    let animals: Color
    let colors: Color
}

extension Palette {
    static let warm = Palette(
        paper:      .hex(0xF4ECDC),
        paperHi:    .hex(0xFBF6EA),
        sand:       .hex(0xE9DCC2),
        ink:        .hex(0x2A2620),
        inkSoft:    .hex(0x6B6056),
        line:       .hex(0xD9CCB1),
        terracotta: .hex(0xC97A4A),
        oak:        .hex(0xB6884A),
        mustard:    .hex(0xD5A845),
        sage:       .hex(0x7FA38B),
        sky:        .hex(0x8AA9BA),
        berry:      .hex(0xB8615A),
        plum:       .hex(0x7A5C7A),
        shapes:     .hex(0xC97A4A),
        numbers:    .hex(0x7A8DB8),
        animals:    .hex(0x7FA38B),
        colors:     .hex(0xD5A845)
    )

    static let cool = Palette(
        paper:      .hex(0xECEEEA),
        paperHi:    .hex(0xF6F7F3),
        sand:       .hex(0xDDE0DA),
        ink:        .hex(0x23282A),
        inkSoft:    .hex(0x5B6266),
        line:       .hex(0xC9CEC8),
        terracotta: .hex(0xA87858),
        oak:        .hex(0x9C8A6A),
        mustard:    .hex(0xB7A45E),
        sage:       .hex(0x6E9685),
        sky:        .hex(0x7E9EAE),
        berry:      .hex(0x9F6A6A),
        plum:       .hex(0x735F75),
        shapes:     .hex(0x7E9EAE),
        numbers:    .hex(0x6E9685),
        animals:    .hex(0x9C8A6A),
        colors:     .hex(0xB7A45E)
    )

    static let neutral = Palette(
        paper:      .hex(0xEFEBE2),
        paperHi:    .hex(0xF8F4EB),
        sand:       .hex(0xE0DACE),
        ink:        .hex(0x27241F),
        inkSoft:    .hex(0x6A6357),
        line:       .hex(0xD4CDBC),
        terracotta: .hex(0xB07A5E),
        oak:        .hex(0xA48A65),
        mustard:    .hex(0xB89A60),
        sage:       .hex(0x88A090),
        sky:        .hex(0x8FA0AA),
        berry:      .hex(0xA4736E),
        plum:       .hex(0x7A6975),
        shapes:     .hex(0xB07A5E),
        numbers:    .hex(0x8FA0AA),
        animals:    .hex(0x88A090),
        colors:     .hex(0xB89A60)
    )
}

private extension Color {
    static func hex(_ value: UInt32) -> Color {
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        return Color(red: r, green: g, blue: b)
    }
}
