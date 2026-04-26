import XCTest
@testable import okawa

class ShortcutConflictCheckerTests: XCTestCase {

  func testNonConflictingShortcutReturnsFalse() {
    // Ctrl+Shift+F19 — extremely unlikely to be a system shortcut
    let shortcut = MASShortcut(
      keyCode: 80, // F19
      modifierFlags: [.control, .shift]
    )
    XCTAssertFalse(ShortcutConflictChecker.isSystemShortcut(shortcut))
  }

  func testIsSystemShortcutDoesNotCrashOnAnyInput() {
    // Verify the function handles various key codes without crashing
    for keyCode in [0, 49, 96, 122, 126] {
      let shortcut = MASShortcut(keyCode: keyCode, modifierFlags: .command)
      _ = ShortcutConflictChecker.isSystemShortcut(shortcut)
    }
  }
}
