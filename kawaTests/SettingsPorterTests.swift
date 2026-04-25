import XCTest
@testable import Kawa

class SettingsPorterTests: XCTestCase {

  // MARK: - T-01: export → import round-trip, ID correct

  func testRoundTripIDCorrect() throws {
    let shortcuts: [(id: String, keyCode: Int?, modifierFlags: Int?)] = [
      (id: "com.apple.keylayout.ABC", keyCode: nil, modifierFlags: nil)
    ]
    let data = SettingsPorter.export(shortcuts: shortcuts)
    let result = try SettingsPorter.importData(data)
    XCTAssertEqual(result.first?.inputSourceID, "com.apple.keylayout.ABC")
  }

  // MARK: - T-02: round-trip with shortcut keyCode

  func testRoundTripKeyCodeCorrect() throws {
    let shortcuts: [(id: String, keyCode: Int?, modifierFlags: Int?)] = [
      (id: "com.apple.keylayout.ABC", keyCode: 96, modifierFlags: 786432)
    ]
    let data = SettingsPorter.export(shortcuts: shortcuts)
    let result = try SettingsPorter.importData(data)
    XCTAssertEqual(result.first?.keyCode, 96)
    XCTAssertEqual(result.first?.modifierFlags, 786432)
  }

  // MARK: - T-03: invalid JSON throws

  func testImportInvalidJSONThrows() {
    let data = "not json".data(using: .utf8)!
    XCTAssertThrowsError(try SettingsPorter.importData(data))
  }

  // MARK: - T-04: unsupported version throws

  func testImportUnsupportedVersionThrows() {
    let json = """
    {"version": 99, "shortcuts": []}
    """.data(using: .utf8)!
    XCTAssertThrowsError(try SettingsPorter.importData(json)) { error in
      XCTAssertTrue(error.localizedDescription.contains("version"))
    }
  }

  // MARK: - T-05: missingSourceIDs returns missing

  func testMissingSourceIDsReturnsMissing() {
    let result = SettingsPorter.missingSourceIDs(in: ["A", "B"], available: ["A"])
    XCTAssertEqual(result, ["B"])
  }

  // MARK: - T-06: missingSourceIDs returns empty when all available

  func testMissingSourceIDsReturnsEmptyWhenAllAvailable() {
    let result = SettingsPorter.missingSourceIDs(in: ["A"], available: ["A", "B"])
    XCTAssertEqual(result, [])
  }
}
