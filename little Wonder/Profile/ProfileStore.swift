import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ProfileStore {
    var name: String {
        didSet { defaults.set(name, forKey: Keys.name) }
    }
    var age: Int {
        didSet { defaults.set(age, forKey: Keys.age) }
    }
    var avatarShape: ShapeKind {
        didSet { defaults.set(avatarShape.rawValue, forKey: Keys.avatarShape) }
    }
    var avatarColor: AvatarColor {
        didSet { defaults.set(avatarColor.rawValue, forKey: Keys.avatarColor) }
    }
    var narrationLanguage: NarrationLanguage {
        didSet { defaults.set(narrationLanguage.rawValue, forKey: Keys.narrationLanguage) }
    }
    var handedness: Handedness {
        didSet { defaults.set(handedness.rawValue, forKey: Keys.handedness) }
    }
    var isNarrationOn: Bool {
        didSet { defaults.set(isNarrationOn, forKey: Keys.isNarrationOn) }
    }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.name = defaults.string(forKey: Keys.name) ?? ""
        self.age = defaults.object(forKey: Keys.age) as? Int ?? 3
        self.avatarShape = defaults.string(forKey: Keys.avatarShape)
            .flatMap { ShapeKind(rawValue: $0) } ?? .circle
        self.avatarColor = defaults.string(forKey: Keys.avatarColor)
            .flatMap { AvatarColor(rawValue: $0) } ?? .terracotta
        self.narrationLanguage = defaults.string(forKey: Keys.narrationLanguage)
            .flatMap { NarrationLanguage(rawValue: $0) } ?? .en
        self.handedness = defaults.string(forKey: Keys.handedness)
            .flatMap { Handedness(rawValue: $0) } ?? .right
        self.isNarrationOn = defaults.object(forKey: Keys.isNarrationOn) as? Bool ?? true
    }

    var displayName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? String(localized: "profileDefaultName")
            : name
    }

    private enum Keys {
        static let name = "profile.name"
        static let age = "profile.age"
        static let avatarShape = "profile.avatarShape"
        static let avatarColor = "profile.avatarColor"
        static let narrationLanguage = "profile.narrationLanguage"
        static let handedness = "profile.handedness"
        static let isNarrationOn = "profile.isNarrationOn"
    }
}
