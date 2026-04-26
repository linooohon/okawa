import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  let statusBar = StatusBar.shared

  var justLaunched: Bool = true

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    promptAccessibilityIfNeeded()

    if PermanentStorage.showsNotification {
      NotificationManager.requestAuthorizationIfNeeded { _ in }
    }
  }

  func applicationDidBecomeActive(_ notification: Notification) {
    guard justLaunched else { return }
    justLaunched = false

    if PermanentStorage.launchedForTheFirstTime {
      PermanentStorage.launchedForTheFirstTime = false
      showPreferences()
    }
  }

  private var isRunningTests: Bool {
    return NSClassFromString("XCTestCase") != nil
  }

  private func promptAccessibilityIfNeeded() {
    guard !isRunningTests else { return }

    let trusted = AXIsProcessTrustedWithOptions(
      [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
    )
    if !trusted {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "okawa needs Accessibility access to switch input sources via shortcuts. Please grant access in System Settings > Privacy & Security > Accessibility, then relaunch the app."
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")
        alert.alertStyle = .warning

        if alert.runModal() == .alertFirstButtonReturn {
          if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
          }
        }
      }
    }
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    NotificationManager.cleanUpTemporaryIcons()
  }

  @IBAction func showPreferences(_ sender: AnyObject? = nil) {
    MainWindowController.shared.showAndActivate(self)
  }

  @IBAction func hidePreferences(_ sender: AnyObject?) {
    MainWindowController.shared.close()
  }
}
