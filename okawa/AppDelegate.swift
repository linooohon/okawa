import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let statusBar = StatusBar.shared

  var justLaunched: Bool = true

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if PermanentStorage.showsNotification {
      NotificationManager.requestAuthorizationIfNeeded { _ in }
    }
  }

  func applicationDidBecomeActive(_ notification: Notification) {
    if !justLaunched || PermanentStorage.launchedForTheFirstTime {
      showPreferences()
    }

    if justLaunched {
      if PermanentStorage.launchedForTheFirstTime {
        PermanentStorage.launchedForTheFirstTime = false
      }
      justLaunched = false
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
