import XCTest
@testable import Kawa

class PermanentStorageTests: XCTestCase {

  private let suiteName = "kawa.test.\(UUID().uuidString)"
  private var originalDefaults: UserDefaults!

  override func setUp() {
    super.setUp()
    originalDefaults = PermanentStorage.defaults
    let testDefaults = UserDefaults(suiteName: suiteName)!
    // Clear the suite
    testDefaults.removePersistentDomain(forName: suiteName)
    PermanentStorage.defaults = testDefaults
  }

  override func tearDown() {
    PermanentStorage.defaults = originalDefaults
    UserDefaults.standard.removePersistentDomain(forName: suiteName)
    super.tearDown()
  }

  // T-01: fresh defaults, showsNotification default
  func testShowsNotificationDefaultIsFalse() {
    XCTAssertFalse(PermanentStorage.showsNotification)
  }

  // T-02: write showsNotification = true, read back
  func testShowsNotificationWriteRead() {
    PermanentStorage.showsNotification = true
    XCTAssertTrue(PermanentStorage.showsNotification)

    PermanentStorage.showsNotification = false
    XCTAssertFalse(PermanentStorage.showsNotification)
  }

  // T-03: fresh defaults, launchedForTheFirstTime default
  func testLaunchedForTheFirstTimeDefaultIsTrue() {
    XCTAssertTrue(PermanentStorage.launchedForTheFirstTime)
  }

  // T-04: write launchedForTheFirstTime = false, read back
  func testLaunchedForTheFirstTimeWriteRead() {
    PermanentStorage.launchedForTheFirstTime = false
    XCTAssertFalse(PermanentStorage.launchedForTheFirstTime)
  }

  // T-05: fresh defaults, inputSourceOrder default
  func testInputSourceOrderDefaultIsEmpty() {
    XCTAssertEqual(PermanentStorage.inputSourceOrder, [])
  }

  // T-06: write inputSourceOrder, read back
  func testInputSourceOrderWriteRead() {
    PermanentStorage.inputSourceOrder = ["A", "B"]
    XCTAssertEqual(PermanentStorage.inputSourceOrder, ["A", "B"])
  }

  // T-07: write empty inputSourceOrder, read back
  func testInputSourceOrderEmptyWriteRead() {
    PermanentStorage.inputSourceOrder = ["A"]
    PermanentStorage.inputSourceOrder = []
    XCTAssertEqual(PermanentStorage.inputSourceOrder, [])
  }
}
