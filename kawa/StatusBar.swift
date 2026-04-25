import AppKit
import Cocoa

class StatusBar {
  static let shared: StatusBar = StatusBar()

  let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

  init() {
    guard let button = item.button else { return }

    button.target = self
    button.action = #selector(StatusBar.action(_:))
    button.appearsDisabled = false
    button.toolTip = "Click to open preferences"

    updateTitle()

    DistributedNotificationCenter.default().addObserver(
      self,
      selector: #selector(inputSourceChanged),
      name: NSNotification.Name("com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged"),
      object: nil
    )
  }

  @objc func action(_ sender: NSButton) {
    MainWindowController.shared.showAndActivate(sender)
  }

  @objc private func inputSourceChanged() {
    DispatchQueue.main.async { [weak self] in
      self?.updateTitle()
    }
  }

  private func updateTitle() {
    let name = InputSource.current?.name ?? ""
    let abbreviation = InputSource.abbreviation(for: name)
    item.button?.title = abbreviation
    item.button?.image = nil
  }
}
