import Cocoa

class PermanentStorage {
  static var defaults: UserDefaults = .standard

  enum StorageKey: String {
    case launchedForTheFirstTime = "launched-for-the-first-time"
    case inputSourceOrder = "input-source-order"
  }

  private static func bool(forKey key: StorageKey, default defaultValue: Bool) -> Bool {
    return defaults.object(forKey: key.rawValue) as? Bool ?? defaultValue
  }

  private static func set(_ value: Bool, forKey key: StorageKey) {
    defaults.set(value, forKey: key.rawValue)
  }

  static var launchedForTheFirstTime: Bool {
    get {
      return bool(forKey: .launchedForTheFirstTime, default: true)
    }
    set {
      set(newValue, forKey: .launchedForTheFirstTime)
    }
  }

  static var inputSourceOrder: [String] {
    get {
      return defaults.array(forKey: StorageKey.inputSourceOrder.rawValue) as? [String] ?? []
    }
    set {
      defaults.set(newValue, forKey: StorageKey.inputSourceOrder.rawValue)
    }
  }
}
