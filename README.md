![logo](resource/png/logo.png)

# okawa [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/utatti/kawa/master/LICENSE)

A lightweight macOS menu bar app that lets you switch input sources with custom keyboard shortcuts. Based on [hatashiro/kawa](https://github.com/hatashiro/kawa/).

## Features

- Assign custom keyboard shortcuts to any input source
- Assign the same shortcut to multiple input sources to cycle through them
- Drag-and-drop to reorder cycling order
- Menu bar shows current input source abbreviation (e.g. `En`, `注音`)
- Desktop notification on input source switch (optional)
- Export/import shortcut settings as JSON
- Launch at login
- Warns when a shortcut conflicts with system shortcuts (e.g. Cmd+Space)

## Requirements

- macOS 10.15 (Catalina) or later
- Accessibility permission (required for switching input sources)

## Install

### Using [Homebrew](https://brew.sh/)

```shell
brew tap linooohon/okawa https://github.com/linooohon/okawa
brew install --cask linooohon/okawa/okawa
```

### Manually

1. Download `okawa.zip` from the latest [Release](https://github.com/linooohon/okawa/releases)
2. Unzip and move `okawa.app` to `/Applications`
3. Since the app is not code-signed, macOS may block it. Run this to allow it:
   ```shell
   xattr -dr com.apple.quarantine /Applications/okawa.app
   ```
4. Open `okawa.app`

## Getting Started

### 1. Grant Accessibility Permission

On first launch, macOS will ask you to grant Accessibility access. This is **required** for okawa to switch input sources via shortcuts.

**System Settings > Privacy & Security > Accessibility > enable okawa**

If you skip this step, shortcuts will be registered but input sources won't actually switch.

### 2. Set Up Shortcuts

The Preferences window opens automatically on first launch. You'll see a list of all available input sources on your system.

- Click the **Shortcut** column next to an input source and press your desired key combination
- The shortcut is saved immediately
- To remove a shortcut, click the shortcut field and press Delete/Backspace

### 3. Cycling Shortcuts

You can assign the **same shortcut** to multiple input sources. Pressing the shortcut will cycle through them in the order shown. Drag rows to change the cycling order.

### 4. Menu Bar

The menu bar shows a 2-character abbreviation of your current input source (e.g. `En`, `注音`). It updates in real time when you switch input sources by any method (okawa shortcut, system menu, or Cmd+Space).

Click the menu bar item to open Preferences.

### 5. Preferences

- **Show notification on input source change** - displays a desktop notification with the input source name and icon when you switch
- **Launch at login** - start okawa automatically when you log in (macOS 13+)
- **Quit okawa** - stops the app and removes the menu bar item

### 6. Export / Import Settings

In Preferences, use the **Export Settings** and **Import Settings** buttons to save or restore your shortcut configuration as a JSON file. Useful when migrating to a new machine.

## Uninstall

### Homebrew

```shell
brew uninstall --cask okawa
brew untap linooohon/okawa
```

### Manual

1. Quit okawa from the menu bar (Preferences > Quit okawa) or `Cmd+Q`
2. Delete `okawa.app` from `/Applications`
3. Remove preferences (optional):
   ```shell
   defaults delete net.noraesae.okawa
   ```

## Known Issues

### CJKV Input Sources

There is a known bug in macOS's Carbon library where `TISSelectInputSource` doesn't work reliably with some complex input sources like [CJKV](https://en.wikipedia.org/wiki/CJK_characters). If switching doesn't work for a specific input source, this is a macOS limitation, not an okawa bug.

## Development

Dependencies are fetched with Swift Package Manager. Open `okawa.xcodeproj` in Xcode and it will resolve packages automatically, or build from the command line:

```bash
# resolve dependencies
xcodebuild -resolvePackageDependencies

# debug build
xcodebuild -scheme okawa -configuration Debug

# run tests
xcodebuild -scheme okawa -destination 'platform=macOS' test

# release build
xcodebuild -scheme okawa -configuration Release -derivedDataPath build
```

### Updating SPM Dependencies

`Package.resolved` is checked into the repository to ensure reproducible builds. To upgrade MASShortcut, update the branch/version in `project.pbxproj`, then run:

```bash
xcodebuild -resolvePackageDependencies
```

Commit the updated `Package.resolved`.

### Release

Push a `v*` tag to trigger the CI release workflow:

```bash
git tag v1.2.0
git push origin v1.2.0
```

GitHub Actions will build the app on macOS 15 (Apple Silicon) and attach `okawa.zip` to the GitHub Release. After the release, update `Casks/okawa.rb` with the sha256 of the zip:

```bash
shasum -a 256 okawa.zip
```

## License

okawa is released under the [MIT License](LICENSE).
