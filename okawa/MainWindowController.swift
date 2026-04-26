import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
  static let shared: MainWindowController = {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateController(withIdentifier: "MainWindow") as! MainWindowController
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
