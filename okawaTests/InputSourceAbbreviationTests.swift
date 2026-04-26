import XCTest
@testable import okawa

class InputSourceAbbreviationTests: XCTestCase {

  func testEnglish() {
    XCTAssertEqual(InputSource.abbreviation(for: "English"), "En")
  }

  func testBopomofo() {
    XCTAssertEqual(InputSource.abbreviation(for: "注音"), "注音")
  }

  func testCangjie() {
    XCTAssertEqual(InputSource.abbreviation(for: "倉頡"), "倉頡")
  }

  func testEmptyString() {
    XCTAssertEqual(InputSource.abbreviation(for: ""), "?")
  }

  func testSingleCharacter() {
    XCTAssertEqual(InputSource.abbreviation(for: "A"), "A")
  }
}
