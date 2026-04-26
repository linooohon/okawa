![logo](resource/png/logo.png)

# okawa [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/utatti/kawa/master/LICENSE)

A macOS input source switcher with user-defined shortcuts. This is a fork of
[utatti/kawa](https://github.com/utatti/kawa) with a refreshed toolchain and new
shortcuts UI.

## Demo

[![demo](https://cloud.githubusercontent.com/assets/1013641/9109734/d73505e4-3c72-11e5-9c71-49cdf4a484da.gif)](http://vimeo.com/135542587)

## Install

### Using [Homebrew](https://brew.sh/)

```shell
brew tap linooohon/okawa https://github.com/linooohon/okawa
brew install --cask linooohon/okawa/okawa
```

### Manually

The prebuilt binaries can be found in [Releases](https://github.com/linooohon/okawa/releases).

Unzip `okawa.zip` and move `okawa.app` to `Applications`.

## Caveats

### CJKV input sources

There is a known bug in the macOS's Carbon library that switching keyboard
layouts using `TISSelectInputSource` doesn't work well with complex input
sources like [CJKV](https://en.wikipedia.org/wiki/CJK_characters).

## Development

Dependencies are fetched with Swift Package Manager. Open `okawa.xcodeproj` in
Xcode and it will resolve packages automatically, or resolve/build from the
command line:

```bash
xcodebuild -resolvePackageDependencies
xcodebuild -scheme okawa -configuration Debug
# run tests:
xcodebuild -scheme okawa -destination 'platform=macOS' test
# release build:
xcodebuild -scheme okawa -configuration Release -derivedDataPath build
```

### Updating SPM dependencies

`Package.resolved` is checked into the repository to ensure reproducible builds.
To upgrade MASShortcut, update the branch/version in `project.pbxproj`, then run:

```bash
xcodebuild -resolvePackageDependencies
```

Commit the updated `Package.resolved`.

## What's new in this fork

- Safe unwrap: all force-cast / force-unwrap removed; app no longer crashes on unexpected Carbon API returns.
- First-launch fix: preferences window now correctly auto-opens on first launch.
- Notifications: fixed identifier prevents stacking; temp icon files are cleaned up; thread-safe delivery.
- Notification auth warning: if notification permission is denied, preferences shows a warning with a link to System Settings.
- Shortcut conflict warning: NSAlert warns when a recorded shortcut conflicts with a system shortcut (e.g. Cmd+Space).
- Menu bar abbreviation: status bar shows 2-char abbreviation of the current input source, updated in real time.
- Launch at login: checkbox in preferences using `SMAppService` (macOS 13+).
- Settings export/import: export shortcut configuration to JSON and import on another machine.
- Shortcut cycling: same shortcut can be assigned to multiple input sources; pressing it cycles through them.
- Drag-to-reorder: input sources are draggable to change their cycling order.
- Modern notifications: uses `UNUserNotificationCenter`.
- Swift 5 + SPM: MASShortcut via Swift Package Manager (no Carthage).
- CI: GitHub Actions on macOS 15 (Apple Silicon).

## License

okawa is released under the [MIT License](LICENSE).
