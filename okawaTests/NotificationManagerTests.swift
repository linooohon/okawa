import XCTest
@testable import okawa

class NotificationManagerTests: XCTestCase {

  // MARK: - cleanUpTemporaryIcons

  func testCleanUpRemovesOkawaIconFiles() {
    let tmpDir = FileManager.default.temporaryDirectory
    let file1 = tmpDir.appendingPathComponent("okawa-icon-aaa.png")
    let file2 = tmpDir.appendingPathComponent("okawa-icon-bbb.png")

    FileManager.default.createFile(atPath: file1.path, contents: Data([0x89]))
    FileManager.default.createFile(atPath: file2.path, contents: Data([0x89]))

    XCTAssertTrue(FileManager.default.fileExists(atPath: file1.path))
    XCTAssertTrue(FileManager.default.fileExists(atPath: file2.path))

    NotificationManager.cleanUpTemporaryIcons()

    XCTAssertFalse(FileManager.default.fileExists(atPath: file1.path))
    XCTAssertFalse(FileManager.default.fileExists(atPath: file2.path))
  }

  func testCleanUpDoesNotCrashWhenNoFiles() {
    // Just verify it doesn't crash when there are no matching files
    NotificationManager.cleanUpTemporaryIcons()
  }

  func testCleanUpExcludesCurrentIcon() {
    let tmpDir = FileManager.default.temporaryDirectory
    let old = tmpDir.appendingPathComponent("okawa-icon-old.png")
    let current = tmpDir.appendingPathComponent("okawa-icon-current.png")

    FileManager.default.createFile(atPath: old.path, contents: Data([0x89]))
    FileManager.default.createFile(atPath: current.path, contents: Data([0x89]))

    NotificationManager.cleanUpTemporaryIcons(excluding: current)

    // old should be removed, current should be preserved
    XCTAssertFalse(FileManager.default.fileExists(atPath: old.path))
    XCTAssertTrue(FileManager.default.fileExists(atPath: current.path))

    // Clean up
    try? FileManager.default.removeItem(at: current)
  }

  func testCleanUpIgnoresNonOkawaFiles() {
    let tmpDir = FileManager.default.temporaryDirectory
    let unrelated = tmpDir.appendingPathComponent("some-other-file.png")

    FileManager.default.createFile(atPath: unrelated.path, contents: Data([0x89]))

    NotificationManager.cleanUpTemporaryIcons()

    XCTAssertTrue(FileManager.default.fileExists(atPath: unrelated.path))

    // Clean up
    try? FileManager.default.removeItem(at: unrelated)
  }

  func testWriteImageReturnsDistinctURLs() {
    let image = NSImage(size: NSSize(width: 16, height: 16))
    image.lockFocus()
    NSColor.red.drawSwatch(in: NSRect(x: 0, y: 0, width: 16, height: 16))
    image.unlockFocus()

    let url1 = NotificationManager.writeImageToTemporaryLocation(image)
    let url2 = NotificationManager.writeImageToTemporaryLocation(image)

    XCTAssertNotNil(url1)
    XCTAssertNotNil(url2)
    XCTAssertNotEqual(url1, url2)

    // Clean up
    if let u1 = url1 { try? FileManager.default.removeItem(at: u1) }
    if let u2 = url2 { try? FileManager.default.removeItem(at: u2) }
  }
}
