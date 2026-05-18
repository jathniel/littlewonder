import SwiftUI

enum FontStack {
    static let display = Font.system(.largeTitle, design: .serif)
        .leading(.tight)
    static let title = Font.custom("Newsreader", size: 44, relativeTo: .largeTitle)
    static let heading = Font.custom("Newsreader", size: 28, relativeTo: .title2)
    static let body = Font.system(.body, design: .rounded).weight(.medium)
    static let label = Font.system(.caption, design: .rounded).weight(.medium).smallCaps()
    static let mono = Font.system(.caption, design: .monospaced)
}
