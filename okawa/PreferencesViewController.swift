import Cocoa
import UniformTypeIdentifiers

extension Notification.Name {
  static let settingsDidImport = Notification.Name("okawa.settingsDidImport")
}

class PreferencesViewController: NSViewController {
  @IBOutlet weak var launchAtLoginCheckbox: NSButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    launchAtLoginCheckbox?.state = LoginItemManager.shared.isEnabled.stateValue
  }

  @IBAction func quitApp(_ sender: NSButton) {
    NSApplication.shared.terminate(nil)
  }

  @IBAction func toggleLaunchAtLogin(_ sender: NSButton) {
    do {
      if sender.state == .on {
        try LoginItemManager.shared.enable()
      } else {
        try LoginItemManager.shared.disable()
      }
    } catch {
      sender.state = LoginItemManager.shared.isEnabled.stateValue
    }
  }

  @IBAction func exportSettings(_ sender: Any?) {
    guard let window = view.window else { return }
    let sources = InputSource.orderedSources(using: PermanentStorage.inputSourceOrder)
    SettingsFileHandler.exportToPanel(from: window, sources: sources)
  }

  @IBAction func importSettings(_ sender: Any?) {
    guard let window = view.window else { return }
    SettingsFileHandler.importFromPanel(from: window) {}
  }
}

private extension Bool {
  var stateValue: NSControl.StateValue {
    return self ? .on : .off
  }
}

private extension NSControl.StateValue {
  var boolValue: Bool {
    return self == .on
  }
}
