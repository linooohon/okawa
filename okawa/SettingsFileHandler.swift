import AppKit
import UniformTypeIdentifiers

enum SettingsFileHandler {

  static func exportToPanel(from window: NSWindow, sources: [InputSource]) {
    let shortcuts: [(id: String, keyCode: Int?, modifierFlags: Int?)] = sources.map { source in
      let key = source.defaultsKey
      if let data = UserDefaults.standard.data(forKey: key),
         let shortcut = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MASShortcut.self, from: data) {
        return (id: source.id, keyCode: Int(shortcut.keyCode), modifierFlags: Int(shortcut.modifierFlags.rawValue))
      }
      return (id: source.id, keyCode: nil, modifierFlags: nil)
    }

    let data: Data
    do {
      data = try SettingsPorter.export(shortcuts: shortcuts)
    } catch {
      showError("Export Failed", detail: error.localizedDescription, in: window)
      return
    }

    let panel = NSSavePanel()
    panel.allowedContentTypes = [.json]
    panel.nameFieldStringValue = "okawa-settings.json"
    panel.beginSheetModal(for: window) { response in
      guard response == .OK, let url = panel.url else { return }
      do {
        try data.write(to: url)
      } catch {
        showError("Export Failed", detail: error.localizedDescription, in: window)
      }
    }
  }

  static func importFromPanel(from window: NSWindow, completion: @escaping () -> Void) {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = [.json]
    panel.allowsMultipleSelection = false
    panel.beginSheetModal(for: window) { response in
      guard response == .OK, let url = panel.url else { return }
      performImport(from: url, window: window)
      completion()
    }
  }

  private static func performImport(from url: URL, window: NSWindow) {
    do {
      let data = try Data(contentsOf: url)
      let entries = try SettingsPorter.importData(data)

      let availableIDs = InputSource.sources.map { $0.id }
      let missing = SettingsPorter.missingSourceIDs(
        in: entries.map { $0.inputSourceID },
        available: availableIDs
      )

      if !missing.isEmpty {
        let alert = NSAlert()
        alert.messageText = "Some input sources not found"
        alert.informativeText = "The following input sources are not available on this system and will be skipped:\n\n" + missing.joined(separator: "\n")
        alert.addButton(withTitle: "Continue")
        alert.addButton(withTitle: "Cancel")
        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }
      }

      for entry in entries {
        let key = InputSource.defaultsKey(for: entry.inputSourceID)
        if let keyCode = entry.keyCode, let flags = entry.modifierFlags {
          let shortcut = MASShortcut(keyCode: keyCode, modifierFlags: NSEvent.ModifierFlags(rawValue: UInt(flags)))
          if let shortcutData = try? NSKeyedArchiver.archivedData(withRootObject: shortcut as Any, requiringSecureCoding: true) {
            UserDefaults.standard.set(shortcutData, forKey: key)
          }
        } else {
          UserDefaults.standard.removeObject(forKey: key)
        }
      }

      NotificationCenter.default.post(name: .settingsDidImport, object: nil)
    } catch {
      showError("Import Failed", detail: error.localizedDescription, in: window)
    }
  }

  private static func showError(_ message: String, detail: String, in window: NSWindow) {
    let alert = NSAlert()
    alert.messageText = message
    alert.informativeText = detail
    alert.beginSheetModal(for: window)
  }
}
