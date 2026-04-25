import Cocoa

class ShortcutCellView: NSTableCellView {
  @IBOutlet weak var shortcutView: MASShortcutView!

  var inputSource: InputSource?
  var shortcutKey: String?
  private var observingRecording = false
  private var kvoContext = 0

  func setInputSource(_ inputSource: InputSource) {
    self.inputSource = inputSource
    shortcutKey = inputSource.id.replacingOccurrences(of: ".", with: "-")

    guard let shortcutKey = shortcutKey else { return }

    shortcutView.associatedUserDefaultsKey = shortcutKey
    shortcutView.shortcutValidator = AlwaysAllowShortcutValidator.sharedValidator
    shortcutView.shortcutValueChange = self.shortcutValueDidChange
    startObservingRecording()
  }

  func shortcutValueDidChange(_ sender: MASShortcutView?) {
    guard let shortcutView = sender, let shortcut = shortcutView.shortcutValue else {
      ShortcutManager.shared.rebuildBindings(with: InputSource.orderedSources(using: PermanentStorage.inputSourceOrder))
      return
    }

    if ShortcutConflictChecker.isSystemShortcut(shortcut) {
      let alert = NSAlert()
      alert.messageText = "Shortcut Conflict"
      alert.informativeText = "This shortcut may conflict with a system function. Are you sure you want to use it?"
      alert.addButton(withTitle: "Keep Using")
      alert.addButton(withTitle: "Reset")
      alert.alertStyle = .warning

      let response = alert.runModal()
      if response == .alertSecondButtonReturn {
        shortcutView.shortcutValue = nil
      }
    }

    ShortcutManager.shared.rebuildBindings(with: InputSource.orderedSources(using: PermanentStorage.inputSourceOrder))
  }

  func selectInput() {
    guard let inputSource = inputSource else { return }

    inputSource.select()

    if PermanentStorage.showsNotification {
      showNotification(inputSource.name, icon: inputSource.icon)
    }
  }

  func showNotification(_ message: String, icon: NSImage?) {
    NotificationManager.deliver(message, icon: icon)
  }

  private func startObservingRecording() {
    guard !observingRecording else { return }
    shortcutView.addObserver(self, forKeyPath: "recording", options: [.new], context: &kvoContext)
    observingRecording = true
  }

  private func stopObservingRecording() {
    guard observingRecording else { return }
    shortcutView.removeObserver(self, forKeyPath: "recording", context: &kvoContext)
    observingRecording = false
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    stopObservingRecording()
  }

  deinit {
    stopObservingRecording()
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard context == &kvoContext, keyPath == "recording", let isRecording = change?[.newKey] as? Bool else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }

    if isRecording {
      ShortcutManager.shared.suspendBindings()
    } else {
      ShortcutManager.shared.resumeBindings()
    }
  }
}
