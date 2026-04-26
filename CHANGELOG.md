## 1.2.0 (26 Apr 2026)

* Refactor: extract import/export logic into SettingsFileHandler
* Refactor: inject ShortcutManager instead of using singleton directly
* Feat: wire Launch at Login checkbox in storyboard
* Feat: prompt for Accessibility permission on launch
* Fix: skip Accessibility prompt during test execution
* Fix: only show preferences on first-ever launch, not every activation
* Test: add ShortcutConflictChecker and first-launch logic tests
* CI: add test job that runs on push/PR, gate release on test pass
* Chore: add SwiftLint config and fix lint violations
* Docs: rewrite README with full install, usage, and uninstall guide

## 1.1.0 (10 Nov 2017)

* Remove previous notifications on new one (#17)

## 1.0.1 (18 Sep 2017)

* Make statusbar icon visible in dark UI

## 1.0.0 (16 Sep 2017)

* Add an option to show macOS notification on source change (#9)
* Implement a proper workaround for the known CJKV bug (#12)
* Update licenses for 2017
* Minor code refactoring

## 0.1.3 (3 Oct 2016)

* Use Swift 3
* Remove 'advanced input switching'

## 0.1.2 (6 Aug 2015)

* Change 'simple method' option to 'advanced method' option.
* Open 'Preferences' initially only for the first launch.

## 0.1.0 (6 Aug 2015)

* Initial release
