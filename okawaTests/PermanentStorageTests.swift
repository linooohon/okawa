import XCTest
@testable import okawa

class PermanentStorageTests: XCTestCase {

  private static let suiteName = "net.noraesae.okawa.tests"
  private var originalDefaults: UserDefaults!
  private var testDefaults: UserDefaults!

  override func setUp() {
    super.setUp()
    originalDefaults = PermanentStorage.defaults
    testDefaults = UserDefaults(suiteName: Self.suiteName)!
    testDefaults.removePersistentDomain(forName: Self.suiteName)
    PermanentStorage.defaults = testDefaults
  }

  override func tearDown() {
    PermanentStorage.defaults = originalDefaults
    testDefaults.removePersistentDomain(forName: Self.suiteName)
    testDefaults.synchronize()
    testDefaults = nil
    super.tearDown()
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
