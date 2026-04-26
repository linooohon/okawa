import XCTest
@testable import okawa

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

  // MARK: - T-07: export empty array, import back

  func testRoundTripEmptyArray() throws {
    let data = SettingsPorter.export(shortcuts: [])
    let result = try SettingsPorter.importData(data)
    XCTAssertEqual(result.count, 0)
  }

  // MARK: - T-08: export 100 items, import back preserves order

  func testRoundTrip100Items() throws {
    let shortcuts: [(id: String, keyCode: Int?, modifierFlags: Int?)] = (0..<100).map {
      (id: "source.\($0)", keyCode: $0, modifierFlags: $0 * 2)
    }
    let data = SettingsPorter.export(shortcuts: shortcuts)
    let result = try SettingsPorter.importData(data)
    XCTAssertEqual(result.count, 100)
    for (i, entry) in result.enumerated() {
      XCTAssertEqual(entry.inputSourceID, "source.\(i)")
      XCTAssertEqual(entry.keyCode, i)
    }
  }

  // MARK: - T-09: import empty Data throws

  func testImportEmptyDataThrows() {
    XCTAssertThrowsError(try SettingsPorter.importData(Data()))
  }

  // MARK: - T-10: import non-JSON plain text throws

  func testImportPlainTextThrows() {
    let data = "hello world".data(using: .utf8)!
    XCTAssertThrowsError(try SettingsPorter.importData(data))
  }

  // MARK: - T-11: import JSON with extra unknown keys succeeds

  func testImportIgnoresUnknownKeys() throws {
    let json = """
    {"version": 1, "shortcuts": [{"inputSourceID": "test", "keyCode": null, "modifierFlags": null}], "extraKey": "ignored"}
    """.data(using: .utf8)!
    let result = try SettingsPorter.importData(json)
    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result[0].inputSourceID, "test")
  }

  // MARK: - T-12: missingSourceIDs both empty

  func testMissingSourceIDsBothEmpty() {
    let result = SettingsPorter.missingSourceIDs(in: [], available: [])
    XCTAssertEqual(result, [])
  }

  // MARK: - T-13: missingSourceIDs imported empty, available non-empty

  func testMissingSourceIDsImportedEmpty() {
    let result = SettingsPorter.missingSourceIDs(in: [], available: ["A"])
    XCTAssertEqual(result, [])
  }
}
