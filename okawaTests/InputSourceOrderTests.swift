import XCTest
@testable import okawa

class InputSourceOrderTests: XCTestCase {

  // MARK: - orderedSources(from:using:)

  func testOrderedSourcesRespectsGivenOrder() {
    let a = InputSource(id: "com.apple.keylayout.A", name: "Alpha")
    let b = InputSource(id: "com.apple.keylayout.B", name: "Bravo")
    let c = InputSource(id: "com.apple.keylayout.C", name: "Charlie")

    let result = InputSource.orderedSources(from: [a, b, c], using: [
      "com.apple.keylayout.C",
      "com.apple.keylayout.A",
      "com.apple.keylayout.B",
    ])

    XCTAssertEqual(result.map(\.id), [
      "com.apple.keylayout.C",
      "com.apple.keylayout.A",
      "com.apple.keylayout.B",
    ])
  }

  func testOrderedSourcesAppendsNewSourcesSortedByName() {
    let a = InputSource(id: "id.A", name: "Zulu")
    let b = InputSource(id: "id.B", name: "Alpha")
    let c = InputSource(id: "id.C", name: "Mike")

    // order only mentions A — B and C are "new" and should be appended sorted by name
    let result = InputSource.orderedSources(from: [a, b, c], using: ["id.A"])

    XCTAssertEqual(result.map(\.id), ["id.A", "id.B", "id.C"])
  }

  func testOrderedSourcesWithEmptyOrderReturnsSortedByName() {
    let a = InputSource(id: "id.A", name: "Zulu")
    let b = InputSource(id: "id.B", name: "Alpha")

    let result = InputSource.orderedSources(from: [a, b], using: [])

    XCTAssertEqual(result.map(\.id), ["id.B", "id.A"])
  }

  func testOrderedSourcesWithNonexistentIDSkipsIt() {
    let a = InputSource(id: "id.A", name: "Alpha")

    let result = InputSource.orderedSources(from: [a], using: ["id.MISSING", "id.A"])

    XCTAssertEqual(result.map(\.id), ["id.A"])
  }

  func testOrderedSourcesWithDuplicateInputIDs() {
    // Simulate two sources with the same ID (should not crash)
    let a1 = InputSource(id: "id.A", name: "Alpha-1")
    let a2 = InputSource(id: "id.A", name: "Alpha-2")

    let result = InputSource.orderedSources(from: [a1, a2], using: ["id.A"])

    XCTAssertEqual(result.count, 1)
    // last one wins in reduce
    XCTAssertEqual(result[0].name, "Alpha-2")
  }

  func testOrderedSourcesEmptyInput() {
    let result = InputSource.orderedSources(from: [], using: ["id.A"])
    XCTAssertEqual(result.count, 0)
  }

  // MARK: - defaultsKey

  func testDefaultsKeyReplacesDots() {
    let source = InputSource(id: "com.apple.keylayout.ABC", name: "ABC")
    XCTAssertEqual(source.defaultsKey, "com-apple-keylayout-ABC")
  }

  func testDefaultsKeyStaticMethod() {
    XCTAssertEqual(InputSource.defaultsKey(for: "com.apple.keylayout.ABC"), "com-apple-keylayout-ABC")
  }

  func testDefaultsKeyWithNoDots() {
    let source = InputSource(id: "NoDots", name: "Test")
    XCTAssertEqual(source.defaultsKey, "NoDots")
  }

  func testDefaultsKeyEmpty() {
    XCTAssertEqual(InputSource.defaultsKey(for: ""), "")
  }
}
