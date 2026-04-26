import XCTest
@testable import okawa

/// Mock LoginItemManager that doesn't touch SMAppService.
/// Verifies the LoginItemManaging protocol contract.
class MockLoginItemManager: LoginItemManaging {
  private(set) var _isEnabled = false
  var shouldThrow = false

  var isEnabled: Bool {
    return _isEnabled
  }

  func enable() throws {
    if shouldThrow { throw NSError(domain: "test", code: 1) }
    _isEnabled = true
  }

  func disable() throws {
    if shouldThrow { throw NSError(domain: "test", code: 2) }
    _isEnabled = false
  }
}

class LoginItemManagerTests: XCTestCase {

  // MARK: - Protocol contract tests using mock

  func testEnableSetsIsEnabled() throws {
    let manager = MockLoginItemManager()
    XCTAssertFalse(manager.isEnabled)

    try manager.enable()
    XCTAssertTrue(manager.isEnabled)
  }

  func testDisableClearsIsEnabled() throws {
    let manager = MockLoginItemManager()
    try manager.enable()
    XCTAssertTrue(manager.isEnabled)

    try manager.disable()
    XCTAssertFalse(manager.isEnabled)
  }

  func testEnableThrowsOnFailure() {
    let manager = MockLoginItemManager()
    manager.shouldThrow = true

    XCTAssertThrowsError(try manager.enable())
    XCTAssertFalse(manager.isEnabled)
  }

  func testDisableThrowsOnFailure() throws {
    let manager = MockLoginItemManager()
    try manager.enable()
    manager.shouldThrow = true

    XCTAssertThrowsError(try manager.disable())
    // State should remain enabled since disable threw
    XCTAssertTrue(manager.isEnabled)
  }

  // MARK: - Real LoginItemManager conformance

  func testSharedConformsToProtocol() {
    // Verify LoginItemManager.shared conforms to LoginItemManaging
    let manager: LoginItemManaging = LoginItemManager.shared
    // isEnabled should return without crashing (actual value depends on system state)
    _ = manager.isEnabled
  }
}
