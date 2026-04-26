import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
  static let shared: MainWindowController = {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    guard let controller = storyboard.instantiateController(withIdentifier: "MainWindow") as? MainWindowController else {
      fatalError("MainWindow controller not found in Main.storyboard — check the storyboard identifier")
    }
    return controller
  }()

  func showAndActivate(_ sender: AnyObject?) {
    self.showWindow(sender)
    self.window?.makeKeyAndOrderFront(sender)
    if #available(macOS 14.0, *) {
      NSApp.activate()
    } else {
      NSApp.activate(ignoringOtherApps: true)
    }
  }

  func windowWillClose(_ notification: Notification) {
    deactivate()
  }

  func deactivate() {
    // focus an application owning the menu bar
    let workspace = NSWorkspace.shared
    if #available(macOS 14.0, *) {
      workspace.menuBarOwningApplication?.activate(from: NSRunningApplication.current)
    } else {
      workspace.menuBarOwningApplication?.activate(options: .activateIgnoringOtherApps)
    }
  }
}
