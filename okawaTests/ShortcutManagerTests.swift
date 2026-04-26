import XCTest
@testable import okawa

class ShortcutManagerTests: XCTestCase {

  private var sources: [InputSource] = []

  override func setUp() {
    super.setUp()
    sources = Array(InputSource.sources.prefix(3))
  }

  // T-01: [A,B,C], current A → next B
  func testNextSourceFromFirstReturnsSecond() {
    guard sources.count >= 3 else { return }
    let next = ShortcutManager.nextSource(after: sources[0].id, within: sources)
    XCTAssertEqual(next?.id, sources[1].id)
  }

  // T-02: [A,B,C], current B → next C
  func testNextSourceFromSecondReturnsThird() {
    guard sources.count >= 3 else { return }
    let next = ShortcutManager.nextSource(after: sources[1].id, within: sources)
    XCTAssertEqual(next?.id, sources[2].id)
  }

  // T-03: [A,B,C], current C → wraps to A
  func testNextSourceFromLastWrapsToFirst() {
    guard sources.count >= 3 else { return }
    let next = ShortcutManager.nextSource(after: sources[2].id, within: sources)
    XCTAssertEqual(next?.id, sources[0].id)
  }

  // T-04: [A,B,C], current nil → first A
  func testNextSourceFromNilReturnsFirst() {
    guard sources.count >= 1 else { return }
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
    guard let first = sources.first else { return }
    let next = ShortcutManager.nextSource(after: first.id, within: [first])
    XCTAssertEqual(next?.id, first.id)
  }

  // T-07: [A,B,C], current X (not in list) → first A
  func testNextSourceUnknownCurrentReturnsFirst() {
    guard sources.count >= 1 else { return }
    let next = ShortcutManager.nextSource(after: "nonexistent.input.source", within: sources)
    XCTAssertEqual(next?.id, sources[0].id)
  }
}
