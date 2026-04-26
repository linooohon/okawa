import XCTest
@testable import okawa

class FirstLaunchLogicTests: XCTestCase {

  private static let suiteName = "net.noraesae.okawa.firstlaunch.tests"
  private var originalDefaults: UserDefaults!

  override func setUp() {
    super.setUp()
    originalDefaults = PermanentStorage.defaults
    let testDefaults = UserDefaults(suiteName: Self.suiteName)!
    testDefaults.removePersistentDomain(forName: Self.suiteName)
    PermanentStorage.defaults = testDefaults
  }

  override func tearDown() {
    PermanentStorage.defaults = originalDefaults
    UserDefaults.standard.removePersistentDomain(forName: Self.suiteName)
    UserDefaults.standard.synchronize()
    super.tearDown()
  }

  func testFirstLaunchFlagIsTrueByDefault() {
    XCTAssertTrue(PermanentStorage.launchedForTheFirstTime)
  }

  func testFirstLaunchFlagIsFalseAfterClearing() {
    PermanentStorage.launchedForTheFirstTime = false
    XCTAssertFalse(PermanentStorage.launchedForTheFirstTime)
  }

  func testFirstLaunchSequence() {
    // Simulate first launch: flag should be true
    XCTAssertTrue(PermanentStorage.launchedForTheFirstTime)

    // After clearing (as AppDelegate does): flag should be false
    PermanentStorage.launchedForTheFirstTime = false
    XCTAssertFalse(PermanentStorage.launchedForTheFirstTime)

    // Second launch: flag stays false
    XCTAssertFalse(PermanentStorage.launchedForTheFirstTime)
  }
}
