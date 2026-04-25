import Cocoa
import UserNotifications

class PreferencesViewController: NSViewController {
  @IBOutlet weak var showNotificationCheckbox: NSButton!
  @IBOutlet weak var launchAtLoginCheckbox: NSButton!

  private var notificationWarningLabel: NSTextField?
  private var openSettingsButton: NSButton?

  override func viewDidLoad() {
    super.viewDidLoad()

    showNotificationCheckbox.state = PermanentStorage.showsNotification.stateValue
    launchAtLoginCheckbox?.state = LoginItemManager.shared.isEnabled.stateValue
    setupNotificationWarningUI()
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    checkNotificationAuthorizationStatus()
  }

  @IBAction func quitApp(_ sender: NSButton) {
    NSApplication.shared.terminate(nil)
  }

  @IBAction func showNotification(_ sender: NSButton) {
    let shouldShow = sender.state.boolValue
    PermanentStorage.showsNotification = shouldShow

    if shouldShow {
      NotificationManager.requestAuthorizationIfNeeded { [weak self] _ in
        DispatchQueue.main.async {
          self?.checkNotificationAuthorizationStatus()
        }
      }
    } else {
      hideNotificationWarning()
    }
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
    let sources = InputSource.orderedSources(using: PermanentStorage.inputSourceOrder)
    let shortcuts: [(id: String, keyCode: Int?, modifierFlags: Int?)] = sources.map { source in
      let key = source.id.replacingOccurrences(of: ".", with: "-")
      if let data = UserDefaults.standard.data(forKey: key),
         let shortcut = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MASShortcut.self, from: data) {
        return (id: source.id, keyCode: Int(shortcut.keyCode), modifierFlags: Int(shortcut.modifierFlags))
      }
      return (id: source.id, keyCode: nil, modifierFlags: nil)
    }

    let data = SettingsPorter.export(shortcuts: shortcuts)

    let panel = NSSavePanel()
    panel.allowedContentTypes = [.json]
    panel.nameFieldStringValue = "kawa-settings.json"
    panel.beginSheetModal(for: view.window!) { response in
      guard response == .OK, let url = panel.url else { return }
      try? data.write(to: url)
    }
  }

  @IBAction func importSettings(_ sender: Any?) {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = [.json]
    panel.allowsMultipleSelection = false
    panel.beginSheetModal(for: view.window!) { [weak self] response in
      guard response == .OK, let url = panel.url else { return }
      self?.performImport(from: url)
    }
  }

  private func performImport(from url: URL) {
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
        let key = entry.inputSourceID.replacingOccurrences(of: ".", with: "-")
        if let keyCode = entry.keyCode, let flags = entry.modifierFlags {
          let shortcut = MASShortcut(keyCode: UInt(keyCode), modifierFlags: UInt(flags))
          if let shortcutData = try? NSKeyedArchiver.archivedData(withRootObject: shortcut as Any, requiringSecureCoding: true) {
            UserDefaults.standard.set(shortcutData, forKey: key)
          }
        } else {
          UserDefaults.standard.removeObject(forKey: key)
        }
      }

      // Reload the shortcut view controller
      if let shortcutVC = children.compactMap({ $0 as? ShortcutViewController }).first {
        shortcutVC.reloadInputSources()
      }
    } catch {
      let alert = NSAlert()
      alert.messageText = "Import Failed"
      alert.informativeText = error.localizedDescription
      alert.runModal()
    }
  }

  // MARK: - Notification warning UI

  private func setupNotificationWarningUI() {
    let label = NSTextField(labelWithString: "Notifications are blocked in System Settings.")
    label.textColor = .systemRed
    label.font = NSFont.systemFont(ofSize: 11)
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    notificationWarningLabel = label

    let button = NSButton(title: "Open System Settings…", target: self, action: #selector(openNotificationSettings))
    button.bezelStyle = .inline
    button.font = NSFont.systemFont(ofSize: 11)
    button.isHidden = true
    button.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(button)
    openSettingsButton = button

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: showNotificationCheckbox.leadingAnchor),
      label.topAnchor.constraint(equalTo: showNotificationCheckbox.bottomAnchor, constant: 4),
      button.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
      button.centerYAnchor.constraint(equalTo: label.centerYAnchor),
    ])
  }

  private func checkNotificationAuthorizationStatus() {
    guard PermanentStorage.showsNotification else {
      hideNotificationWarning()
      return
    }

    NotificationManager.checkAuthorizationStatus { [weak self] status in
      DispatchQueue.main.async {
        if status == .denied {
          self?.showNotificationWarning()
        } else {
          self?.hideNotificationWarning()
        }
      }
    }
  }

  private func showNotificationWarning() {
    notificationWarningLabel?.isHidden = false
    openSettingsButton?.isHidden = false
  }

  private func hideNotificationWarning() {
    notificationWarningLabel?.isHidden = true
    openSettingsButton?.isHidden = true
  }

  @objc private func openNotificationSettings() {
    let bundleId = Bundle.main.bundleIdentifier ?? ""
    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications?id=\(bundleId)") {
      NSWorkspace.shared.open(url)
    }
  }
}

private extension Bool {
  var stateValue: NSControl.StateValue {
    return self ? .on : .off;
  }
}

private extension NSControl.StateValue {
  var boolValue: Bool {
    return self == .on;
  }
}
