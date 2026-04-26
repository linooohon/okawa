import Foundation

class ShortcutManager {
  static let shared = ShortcutManager()

  private let monitor = MASShortcutMonitor.shared()
  private var currentSources: [InputSource] = []
  private var isSuspended: Bool = false

  func rebuildBindings(with sources: [InputSource]) {
    currentSources = sources
    guard !isSuspended else { return }

    monitor?.unregisterAllShortcuts()

    let grouped = groupSourcesByShortcut(from: sources)

    for (shortcut, inputSources) in grouped {
      monitor?.register(shortcut, withAction: { [weak self] in
        self?.cycle(shortcut: shortcut, within: inputSources)
      })
    }
  }

  func suspendBindings() {
    isSuspended = true
    monitor?.unregisterAllShortcuts()
  }

  func resumeBindings() {
    isSuspended = false
    rebuildBindings(with: currentSources)
  }

  private func groupSourcesByShortcut(from sources: [InputSource]) -> [MASShortcut: [InputSource]] {
    var grouped: [MASShortcut: [InputSource]] = [:]

    for source in sources {
      guard let shortcutKey = shortcutDefaultsKey(for: source),
        let shortcut = shortcut(for: shortcutKey)
        else { continue }

      grouped[shortcut, default: []].append(source)
    }

    return grouped
  }

  static func nextSource(after currentId: String?, within sources: [InputSource]) -> InputSource? {
    guard !sources.isEmpty else { return nil }

    if let currentId = currentId,
       let currentIndex = sources.firstIndex(where: { $0.id == currentId }) {
      let nextIndex = (currentIndex + 1) % sources.count
      return sources[nextIndex]
    } else {
      return sources[0]
    }
  }

  private func cycle(shortcut: MASShortcut, within sources: [InputSource]) {
    guard let next = ShortcutManager.nextSource(after: InputSource.current?.id, within: sources) else { return }

    next.select()

    if PermanentStorage.showsNotification {
      NotificationManager.deliver(next.name, icon: next.icon)
    }
  }

  private func shortcutDefaultsKey(for source: InputSource) -> String? {
    return source.defaultsKey
  }

  private func shortcut(for key: String) -> MASShortcut? {
    guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
    return try? NSKeyedUnarchiver.unarchivedObject(ofClass: MASShortcut.self, from: data)
  }
}
