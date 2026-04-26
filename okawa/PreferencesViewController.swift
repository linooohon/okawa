import Cocoa
import UniformTypeIdentifiers
import UserNotifications

extension Notification.Name {
  static let settingsDidImport = Notification.Name("okawa.settingsDidImport")
}

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
    guard let window = view.window else { return }
    let sources = InputSource.orderedSources(using: PermanentStorage.inputSourceOrder)
    SettingsFileHandler.exportToPanel(from: window, sources: sources)
  }

  @IBAction func importSettings(_ sender: Any?) {
    guard let window = view.window else { return }
    SettingsFileHandler.importFromPanel(from: window) {}
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
