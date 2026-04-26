import AppKit
import Foundation
import UserNotifications

enum NotificationManager {
  private static let notificationIdentifier = "okawa.input-source-switch"
  private static let iconFilePrefix = "okawa-icon-"

  static func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .authorized, .provisional, .ephemeral:
        completion(true)
      case .notDetermined:
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
          completion(granted)
        }
      case .denied:
        completion(false)
      @unknown default:
        completion(false)
      }
    }
  }

  static func deliver(_ message: String, icon: NSImage?) {
    requestAuthorizationIfNeeded { granted in
      guard granted else { return }

      DispatchQueue.main.async {
        let content = UNMutableNotificationContent()
        content.body = message

        if let image = icon, let attachment = createAttachment(from: image) {
          content.attachments = [attachment]
        }

        let request = UNNotificationRequest(
          identifier: notificationIdentifier,
          content: content,
          trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { _ in
          cleanUpTemporaryIcons()
        }
      }
    }
  }

  static func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      completion(settings.authorizationStatus)
    }
  }

  static func cleanUpTemporaryIcons() {
    let tmpDir = FileManager.default.temporaryDirectory
    guard let contents = try? FileManager.default.contentsOfDirectory(
      at: tmpDir, includingPropertiesForKeys: nil
    ) else { return }

    for url in contents where url.lastPathComponent.hasPrefix(iconFilePrefix)
      && url.pathExtension == "png" {
      try? FileManager.default.removeItem(at: url)
    }
  }

  private static func createAttachment(from image: NSImage) -> UNNotificationAttachment? {
    guard let url = writeImageToTemporaryLocation(image) else { return nil }
    return try? UNNotificationAttachment(identifier: "okawa-icon", url: url, options: nil)
  }

  static func writeImageToTemporaryLocation(_ image: NSImage) -> URL? {
    guard
      let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let pngData = bitmap.representation(using: .png, properties: [:])
    else { return nil }

    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("\(iconFilePrefix)\(UUID().uuidString).png")

    do {
      try pngData.write(to: url)
      return url
    } catch {
      return nil
    }
  }
}
