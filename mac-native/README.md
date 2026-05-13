# Claude Pomodoro — Mac-native rewrite (experimental)

SwiftUI port of the Electron app. Same UI, same features, ~3MB binary instead of 90MB.

**Status:** untested. Written in one pass without a compile-test. Expect minor bugs. Issues, PRs welcome.

## Why this exists

The Electron app is 90MB because it bundles Chromium + Node.js. This rewrite uses the OS's native AppKit + SwiftUI, so the binary is the OS's stuff plus a few hundred KB of your code.

Trade-off: macOS only. The Electron build remains the cross-platform option.

## Requirements

- macOS 13 (Ventura) or later
- Xcode 15+ **or** the Swift toolchain (`xcode-select --install` is enough for the CLI)

## Build & run

```bash
cd mac-native
swift run                     # debug build, runs the app
swift build -c release        # release binary at .build/release/ClaudePomodoro
```

Or open `Package.swift` in Xcode for a normal IDE experience.

## Package as a `.app`

`swift build` produces a CLI executable, not a bundled `.app`. To make a redistributable app:

1. Open `Package.swift` in Xcode (File → Open → select `Package.swift`).
2. Set the run destination to "My Mac".
3. Product → Archive.
4. In the Organizer window: Distribute App → Copy App → choose a location.

The output `.app` will be ~3–5MB. Code signing rules still apply — without an Apple Developer cert, users will still see the "Apple could not verify" warning on first launch.

## File layout

```
mac-native/
├── Package.swift                       # Swift Package Manager config
└── Sources/ClaudePomodoro/
    ├── ClaudePomodoroApp.swift         # @main entry point + window config
    ├── ContentView.swift               # the UI
    ├── TimerModel.swift                # @ObservableObject with timer state
    ├── AnimatedGIFView.swift           # NSImageView wrapped for SwiftUI (plays animated GIFs)
    └── Resources/
        ├── work.gif                    # hammering mascot, used during focus
        └── done.gif                    # idle mascot, used during break / when stopped
```

## Feature parity vs Electron version

| Feature | Status |
| ------- | ------ |
| 25/5 timer with start/pause/reset | Implemented |
| Custom focus duration (5/15/25 presets + custom input) | Implemented |
| Pixel-art mascot animation | Implemented (via `NSImageView`) |
| Always-on-top with pin/unpin toggle | Implemented (sets `NSWindow.level`) |
| Frameless transparent window | Implemented |
| Drag from titlebar | Implemented (`isMovableByWindowBackground`) |
| Native notifications | Implemented (UNUserNotificationCenter) |
| Session counter | Implemented |
| Custom window close/minimize buttons | Implemented |

## Known gaps / things to verify when you build

- **Notifications under `swift run`**: `UNUserNotificationCenter` requires a proper `.app` bundle. The code guards on `Bundle.main.bundleIdentifier != nil`, so under `swift run` the timer works but notifications are silently skipped. To get notifications, build a `.app` (see section above).
- **Window sizing**: SwiftUI on macOS is finicky about fixed-size frameless windows. The `.frame(width:height:)` combined with `WindowConfigurator` *should* give you 280×380, but you might need to tweak `windowResizability` if it ends up resizable.
- **GIF looping**: `NSImageView.animates = true` should loop animated GIFs natively. If looping stops after one cycle, the GIF might need `NSBitmapImageRep.PropertyKey.loopCount` set to 0 — easy fix, not currently done.
- **Custom input field**: the `.onChange(of:)` API signature changed in macOS 14. The code uses the older two-arg form — if you're on macOS 14+ you may need to update to the closure form.
- **App lifecycle**: closing the window currently quits the app. To match Electron's "minimize to nothing" behavior on Mac, you'd need to handle `applicationShouldTerminateAfterLastWindowClosed`.

## License

Same MIT as the parent project.
