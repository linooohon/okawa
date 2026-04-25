import Foundation

enum SettingsPorterError: LocalizedError {
  case invalidFormat
  case unsupportedVersion(Int)

  var errorDescription: String? {
    switch self {
    case .invalidFormat:
      return "The file is not a valid Kawa settings file."
    case .unsupportedVersion(let v):
      return "Unsupported settings version: \(v). This app supports version 1."
    }
  }
}

enum SettingsPorter {
  private struct SettingsFile: Codable {
    let version: Int
    let shortcuts: [ShortcutEntry]
  }

  struct ShortcutEntry: Codable {
    let inputSourceID: String
    let keyCode: Int?
    let modifierFlags: Int?
  }

  static func export(shortcuts: [(id: String, keyCode: Int?, modifierFlags: Int?)]) -> Data {
    let entries = shortcuts.map {
      ShortcutEntry(inputSourceID: $0.id, keyCode: $0.keyCode, modifierFlags: $0.modifierFlags)
    }
    let file = SettingsFile(version: 1, shortcuts: entries)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return (try? encoder.encode(file)) ?? Data()
  }

  static func importData(_ data: Data) throws -> [ShortcutEntry] {
    let decoder = JSONDecoder()
    let file: SettingsFile
    do {
      file = try decoder.decode(SettingsFile.self, from: data)
    } catch {
      throw SettingsPorterError.invalidFormat
    }

    guard file.version == 1 else {
      throw SettingsPorterError.unsupportedVersion(file.version)
    }

    return file.shortcuts
  }

  static func missingSourceIDs(in imported: [String], available: [String]) -> [String] {
    let availableSet = Set(available)
    return imported.filter { !availableSet.contains($0) }
  }
}
