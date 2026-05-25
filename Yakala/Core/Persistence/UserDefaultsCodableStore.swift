import Foundation

enum UserDefaultsCodableStore {
    static func load<Value: Codable>(_ type: Value.Type, forKey key: String, defaultValue: Value) -> Value {
        guard
            let jsonString = UserDefaults.standard.string(forKey: key),
            let data = jsonString.data(using: .utf8),
            let value = try? JSONDecoder().decode(Value.self, from: data)
        else {
            return defaultValue
        }

        return value
    }

    static func save<Value: Codable>(_ value: Value, forKey key: String) {
        guard
            let data = try? JSONEncoder().encode(value),
            let jsonString = String(data: data, encoding: .utf8)
        else {
            return
        }

        UserDefaults.standard.set(jsonString, forKey: key)
    }
}

