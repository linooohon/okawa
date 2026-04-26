import XCTest
@testable import okawa

class ShortcutManagerTests: XCTestCase {

  private var sources: [InputSource] = []

  override func setUp() {
    super.setUp()
    sources = [
      InputSource(id: "com.test.A", name: "Alpha"),
      InputSource(id: "com.test.B", name: "Bravo"),
      InputSource(id: "com.test.C", name: "Charlie"),
    ]
  }

  // T-01: [A,B,C], current A → next B
  func testNextSourceFromFirstReturnsSecond() {
    let next = ShortcutManager.nextSource(after: sources[0].id, within: sources)
    XCTAssertEqual(next?.id, sources[1].id)
  }

  // T-02: [A,B,C], current B → next C
  func testNextSourceFromSecondReturnsThird() {
    let next = ShortcutManager.nextSource(after: sources[1].id, within: sources)
    XCTAssertEqual(next?.id, sources[2].id)
  }

  // T-03: [A,B,C], current C → wraps to A
  func testNextSourceFromLastWrapsToFirst() {
    let next = ShortcutManager.nextSource(after: sources[2].id, within: sources)
    XCTAssertEqual(next?.id, sources[0].id)
  }

  // T-04: [A,B,C], current nil → first A
  func testNextSourceFromNilReturnsFirst() {
    let next = ShortcutManager.nextSource(after: nil, within: sources)
    XCTAssertEqual(next?.id, sources[0].id)
  }

  // T-05: empty list → nil
  func testNextSourceEmptyListReturnsNil() {
    let next = ShortcutManager.nextSource(after: nil, within: [])
    XCTAssertNil(next)
  }

  // T-06: [A], current A → A (self-cycle)
  func testNextSourceSingleElementSelfCycles() {
    let single = [sources[0]]
    let next = ShortcutManager.nextSource(after: sources[0].id, within: single)
    XCTAssertEqual(next?.id, sources[0].id)
  }

  // T-07: [A,B,C], current X (not in list) → first A
  func testNextSourceUnknownCurrentReturnsFirst() {
    let next = ShortcutManager.nextSource(after: "nonexistent.input.source", within: sources)
    XCTAssertEqual(next?.id, sources[0].id)
  }
}
