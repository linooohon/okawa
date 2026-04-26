import Foundation

enum ShortcutConflictChecker {
  static func isSystemShortcut(_ shortcut: MASShortcut) -> Bool {
    let validator = MASShortcutValidator.shared()
    var explanation: NSString?
    return validator?.isShortcutAlreadyTaken(bySystem: shortcut, explanation: &explanation) ?? false
  }
}
