import XCTest
@testable import okawa

// These tests verify that TISInputSource extension properties
// return safe fallback values when Carbon returns nil or unexpected types.
// Since TISInputSource is an opaque Carbon type we cannot easily mock it,
// we instead test via the live system input sources and verify the contract:
// all properties must return without crashing.

class TISInputSourceTests: XCTestCase {

  // MARK: - Live input source safety tests

  func testCurrentInputSourcePropertiesDoNotCrash() {
    // Get any real input source from the system
    guard let list = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource],
          let source = list.first else {
      // CI or sandboxed environment may have no sources — skip gracefully
      return
    }

    // These must not crash — that is the assertion
    _ = source.id
    _ = source.name
    _ = source.category
    _ = source.isSelectable
    _ = source.sourceLanguages
    _ = source.iconImageURL
    _ = source.iconRef
  }

  func testAllInputSourcesReturnNonCrashingValues() {
    guard let list = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else {
      return
    }

    for source in list {
      // id and name should be non-empty for valid sources, but the main contract
      // is "no crash". We verify they return strings.
      XCTAssertNotNil(source.id as String?)
      XCTAssertNotNil(source.name as String?)
      XCTAssertNotNil(source.category as String?)
      _ = source.isSelectable
      _ = source.sourceLanguages
    }
  }

  // MARK: - InputSource.icon fallback

  func testInputSourceIconDoesNotCrashOnAnySource() {
    let sources = InputSource.sources
    for source in sources {
      // icon may be nil, but must not crash
      _ = source.icon
    }
  }
}
