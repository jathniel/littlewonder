import Foundation
import Observation

@MainActor
@Observable
final class ThemeSettings {
    var paletteMode: PaletteMode {
        didSet { persist(paletteMode, key: Self.paletteKey) }
    }

    var paceMode: PaceMode {
        didSet { persist(paceMode, key: Self.paceKey) }
    }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.paletteMode = Self.load(PaletteMode.self, key: Self.paletteKey, from: defaults) ?? .warm
        self.paceMode = Self.load(PaceMode.self, key: Self.paceKey, from: defaults) ?? .slow
    }

    private static let paletteKey = "littleWonder.paletteMode"
    private static let paceKey = "littleWonder.paceMode"

    private func persist<T: RawRepresentable>(_ value: T, key: String) where T.RawValue == String {
        defaults.set(value.rawValue, forKey: key)
    }

    private static func load<T: RawRepresentable>(_ type: T.Type, key: String, from defaults: UserDefaults) -> T? where T.RawValue == String {
        guard let raw = defaults.string(forKey: key) else { return nil }
        return T(rawValue: raw)
    }
}
