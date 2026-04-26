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
    return SMAppService.mainApp.status == .enabled
  }

  func enable() throws {
    try SMAppService.mainApp.register()
  }

  func disable() throws {
    try SMAppService.mainApp.unregister()
  }
}
