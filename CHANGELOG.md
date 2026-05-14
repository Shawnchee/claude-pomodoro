# Changelog

Notable changes per release. Pre-1.0 is fluid — minor bumps can change behavior.

## [0.2.0] - 2026-05-14

**Added**
- Persistent settings — work / break / long-break / cycle / sound / pin all survive restart. `electron-store` on Electron, `UserDefaults` on SwiftUI.
- Configurable break duration with 3 / 5 / 10 minute presets and a custom input.
- Long break every N work sessions (default 4) — classic pomodoro cycle.
- Sound on phase change — `celebratory.wav` (3s, trimmed) plays via HTML5 Audio (Electron) / `AVAudioPlayer` (SwiftUI). One toggle controls both the chime and the OS notification sound.
- Settings UI — gear button in the titlebar flips the card to an in-window settings view, vertically centered. Same pattern on both builds.
- Demo video embedded at the top of the README.

**Fixed**
- Windows notifications silently dropped because no `AppUserModelID` was set. `app.setAppUserModelId('com.shawnchee.claudepomodoro')` before `whenReady` now actually delivers Win10/11 toasts.
- macOS notifications not showing while the app was frontmost. `UNUserNotificationCenter` delegate now returns `.banner` from `willPresent`, so banners surface instead of going straight to Notification Center.

**Changed**
- Extracted `BundleResources` helper so the SPM bundle lookup is shared between the GIF view and the audio player.

## [0.1.7] - 2026-05-14
- macOS: add app icon to the SwiftUI native build.

## [0.1.6] - 2026-05-14
- macOS: load resource bundle from `Contents/Resources/` so `codesign --deep` succeeds.

## [0.1.5] - 2026-05-14
- macOS: ad-hoc sign only the binary, not the entire bundle.

## [0.1.4] - 2026-05-14
- macOS: place the SPM resource bundle at the `.app` root so `Bundle.module` finds it. Fixes the v0.1.3 runtime crash.

## [0.1.3] - 2026-05-14
- macOS: migrate to a native SwiftUI build. DMG drops from 98MB to ~726KB.
- CI: split into separate `build-mac-native` and `build-electron` jobs.
- CI: normalize Electron artifact filenames so the Homebrew cask URL pattern stays stable.

## [0.1.2] - 2026-05-14
- CI: pass `--publish=never` to electron-builder so the implicit tag-publish doesn't fail without `GH_TOKEN`.

## [0.1.1] - 2026-05-14
- CI: stop electron-builder from auto-publishing.
- Distribution: personal Homebrew tap published at `Shawnchee/homebrew-claude-pomodoro`.

## [0.1.0] - 2026-05-14
Initial release. Pixel-art pomodoro with always-on-top floating window, 25/5 cycles, mascot animations, native notifications. Cross-platform via Electron.

[0.2.0]: https://github.com/Shawnchee/claude-pomodoro/releases/tag/v0.2.0
[0.1.7]: https://github.com/Shawnchee/claude-pomodoro/releases/tag/v0.1.7
[0.1.6]: https://github.com/Shawnchee/claude-pomodoro/releases/tag/v0.1.6
[0.1.5]: https://github.com/Shawnchee/claude-pomodoro/releases/tag/v0.1.5
[0.1.4]: https://github.com/Shawnchee/claude-pomodoro/releases/tag/v0.1.4
[0.1.3]: https://github.com/Shawnchee/claude-pomodoro/releases/tag/v0.1.3
[0.1.2]: https://github.com/Shawnchee/claude-pomodoro/releases/tag/v0.1.2
[0.1.1]: https://github.com/Shawnchee/claude-pomodoro/releases/tag/v0.1.1
[0.1.0]: https://github.com/Shawnchee/claude-pomodoro/releases/tag/v0.1.0
