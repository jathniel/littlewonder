import Foundation
import Observation

@MainActor
@Observable
final class ThemeSettings {
    var paletteMode: PaletteMode {
        didSet { Self.persist(paletteMode, key: Self.paletteKey) }
    }

    var paceMode: PaceMode {
        didSet { Self.persist(paceMode, key: Self.paceKey) }
    }

    init() {
        self.paletteMode = Self.load(PaletteMode.self, key: Self.paletteKey) ?? .warm
        self.paceMode = Self.load(PaceMode.self, key: Self.paceKey) ?? .slow
    }

    private static let paletteKey = "littleWonder.paletteMode"
    private static let paceKey = "littleWonder.paceMode"

    private static func persist<T: RawRepresentable>(_ value: T, key: String) where T.RawValue == String {
        UserDefaults.standard.set(value.rawValue, forKey: key)
    }

    private static func load<T: RawRepresentable>(_ type: T.Type, key: String) -> T? where T.RawValue == String {
        guard let raw = UserDefaults.standard.string(forKey: key) else { return nil }
        return T(rawValue: raw)
    }
}
