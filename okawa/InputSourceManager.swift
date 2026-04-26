import Carbon
import Cocoa

class InputSource {
  private let tisInputSource: TISInputSource?
  let id: String
  let name: String
  let icon: NSImage?

  init(tisInputSource: TISInputSource) {
    self.tisInputSource = tisInputSource
    self.id = tisInputSource.id
    self.name = tisInputSource.name

    var iconImage: NSImage? = nil

    if let imageURL = tisInputSource.iconImageURL {
      for url in [imageURL.retinaImageURL, imageURL.tiffImageURL, imageURL] {
        if let image = NSImage(contentsOf: url) {
          iconImage = image
          break
        }
      }
    }

    // iconRef is the only fallback when iconImageURL is unavailable.
    // NSImage(iconRef:) is deprecated but Carbon IconRef has no modern
    // replacement — this will remain until Apple provides an alternative.
    if iconImage == nil, let iconRef = tisInputSource.iconRef {
      iconImage = Self.imageFromIconRef(iconRef)
    }

    self.icon = iconImage
  }

  /// Test-only initializer for creating InputSource without Carbon API.
  init(id: String, name: String, icon: NSImage? = nil) {
    self.tisInputSource = nil
    self.id = id
    self.name = name
    self.icon = icon
  }

  func select() {
    guard let tisInputSource else { return }
    TISSelectInputSource(tisInputSource)
  }

  @available(macOS, deprecated: 10.15, message: "No replacement for Carbon IconRef")
  private static func imageFromIconRef(_ iconRef: IconRef) -> NSImage {
    return NSImage(iconRef: iconRef)
  }
}

extension InputSource: Equatable {
  static func == (lhs: InputSource, rhs: InputSource) -> Bool {
    return lhs.id == rhs.id
  }
}

extension InputSource {
  static var sources: [InputSource] {
    guard let unmanagedList = TISCreateInputSourceList(nil, false) else { return [] }
    let inputSourceNSArray = unmanagedList.takeRetainedValue() as NSArray
    guard let inputSourceList = inputSourceNSArray as? [TISInputSource] else { return [] }

    return inputSourceList
      .filter {
        $0.category == TISInputSource.Category.keyboardInputSource && $0.isSelectable
    }.map {
      InputSource(tisInputSource: $0)
    }
  }

  static func orderedSources(using order: [String]) -> [InputSource] {
    return orderedSources(from: sources, using: order)
  }

  /// Core ordering logic, separated for testability.
  static func orderedSources(from allSources: [InputSource], using order: [String]) -> [InputSource] {
    var ordered: [InputSource] = []
    // Use reduce to handle potential duplicate IDs (last one wins)
    var remaining = allSources.reduce(into: [String: InputSource]()) { $0[$1.id] = $1 }

    for id in order {
      if let source = remaining.removeValue(forKey: id) {
        ordered.append(source)
      }
    }

    // append any new sources that were not previously saved
    ordered.append(contentsOf: remaining.values.sorted { $0.name < $1.name })
    return ordered
  }

  static var current: InputSource? {
    guard let current = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else { return nil }
    return InputSource(tisInputSource: current)
  }

  static func defaultsKey(for inputSourceID: String) -> String {
    return inputSourceID.replacingOccurrences(of: ".", with: "-")
  }

  var defaultsKey: String {
    return InputSource.defaultsKey(for: id)
  }

  static func abbreviation(for name: String) -> String {
    guard !name.isEmpty else { return "?" }
    return String(name.prefix(2))
  }
}

private extension URL {
  var retinaImageURL: URL {
    var components = pathComponents
    let filename: String = components.removeLast()
    let ext: String = pathExtension
    let retinaFilename = filename.replacingOccurrences(of: "." + ext, with: "@2x." + ext)
    guard let url = NSURL.fileURL(withPathComponents: components + [retinaFilename]) else { return self }
    return url
  }

  var tiffImageURL: URL {
    return deletingPathExtension().appendingPathExtension("tiff")
  }
}
