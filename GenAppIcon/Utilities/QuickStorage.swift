//
//  QuickStorage.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 04/03/2023.
//

import Foundation

class QuickStorage {
    var lastUploadedLogo: Data? {
        get { UserDefaults.lastUploadedLogo }
        set { UserDefaults.lastUploadedLogo = newValue }
    }
}

extension UserDefaults {
    @UserDefaultObject(key: .lastUploadedLogo, container: .appGroup)
    fileprivate static var lastUploadedLogo: Data?

    private static let appGroup: UserDefaults = UserDefaults(suiteName: Constants.Identifiers.appGroup)!
}

@propertyWrapper
private struct UserDefaultObject<Value: Codable> {
    let key: Keys
    let container: UserDefaults?

    init(key: Keys, container: UserDefaults? = .standard) {
        self.key = key
        self.container = container
    }

    enum Keys: String {
        case lastUploadedLogo
    }

    var wrappedValue: Value? {
        get {
            guard let container, let data = container.object(forKey: constructedKey) as? Data else { return nil }

            return try? JSONDecoder().decode(Value.self, from: data)
        }
        set {
            guard let container, let data = try? JSONEncoder().encode(newValue) else { return }

            container.set(data, forKey: constructedKey)
        }
    }

    var projectedValue: UserDefaultObject { self }

    func removeValue() {
        container?.removeObject(forKey: constructedKey)
    }

    private var constructedKey: String {
        "\(Constants.Identifiers.app).UserDefaults.\(key.rawValue)"
    }
}
