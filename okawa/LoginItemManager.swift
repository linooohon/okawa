import Foundation
import ServiceManagement

protocol LoginItemManaging {
  var isEnabled: Bool { get }
  func enable() throws
  func disable() throws
}

class LoginItemManager: LoginItemManaging {
  static let shared = LoginItemManager()

  var isEnabled: Bool {
    if #available(macOS 13.0, *) {
      return SMAppService.mainApp.status == .enabled
    } else {
      return PermanentStorage.launchAtLogin
    }
  }

  func enable() throws {
    if #available(macOS 13.0, *) {
      try SMAppService.mainApp.register()
    }
    PermanentStorage.launchAtLogin = true
  }

  func disable() throws {
    if #available(macOS 13.0, *) {
      try SMAppService.mainApp.unregister()
    }
    PermanentStorage.launchAtLogin = false
  }
}
