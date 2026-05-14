# Claude Pomodoro

A cute pixel-art pomodoro timer that lives in a floating always-on-top window. Cross-platform: macOS, Windows, Linux.

<p align="center">
  <video src="https://github.com/Shawnchee/claude-pomodoro/raw/master/docs/demo.mov" controls muted width="480"></video>
</p>

<p align="center">
  <img src="build/icon.png" alt="Claude Pomodoro icon" width="160" />
</p>

## Download

All installers live on the [Releases page](https://github.com/Shawnchee/claude-pomodoro/releases/latest). The app is unsigned on every platform, so expect a one-time security warning on first launch — workarounds are inline below.

### macOS

Apple Silicon (M1/M2/M3/M4) only. Intel Macs can run it under Rosetta or wait for a future universal build.

**Option A — Homebrew (recommended)**

```bash
brew install --cask shawnchee/claude-pomodoro/claude-pomodoro
xattr -d com.apple.quarantine "/Applications/Claude Pomodoro.app"
open -a "Claude Pomodoro"
```

The `xattr` line strips the quarantine flag that triggers macOS Gatekeeper. One-time per install. Updates come via `brew upgrade --cask claude-pomodoro`.

**Option B — Direct download**

1. Download the latest `Claude-Pomodoro-*-arm64.dmg` from the [Releases page](https://github.com/Shawnchee/claude-pomodoro/releases/latest).
2. Open the `.dmg` and drag **Claude Pomodoro** into **Applications**.
3. The first time you launch it, macOS shows *"Apple could not verify 'Claude Pomodoro' is free of malware."* This is expected — the app is unsigned. To clear it:
   - Open **System Settings → Privacy & Security**
   - Scroll to the Security section, click **Open Anyway** next to the blocked app
   - Re-launch and confirm in the dialog
4. After this, it opens normally from Launchpad/Spotlight forever.

Either path produces the same `.app` — option A just spares you the System Settings dance.

### Windows

Download the latest `Claude-Pomodoro-Setup-*.exe` from the [Releases page](https://github.com/Shawnchee/claude-pomodoro/releases/latest) (x64).

1. Run the installer.
2. When Windows SmartScreen shows *"Windows protected your PC"*, click **More info** → **Run anyway**.
3. Follow the installer wizard.

The app will appear in your Start menu as **Claude Pomodoro**.

### Linux

Download the latest `Claude-Pomodoro-*.AppImage` from the [Releases page](https://github.com/Shawnchee/claude-pomodoro/releases/latest) (x64).

```bash
chmod +x Claude-Pomodoro-*.AppImage
./Claude-Pomodoro-*.AppImage
```

No security prompt — AppImages run as the executing user. To integrate it into your application menu, use a tool like [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher).

## Features

- Configurable focus, break, and long-break durations (presets + free-form custom)
- Long break every N sessions (classic pomodoro cycle, default every 4)
- Start / pause / reset
- Always-on-top floating window (drag from the title bar)
- Pixel-art mascot — hammers during focus, idles during break
- Native OS notifications when phases switch (with an optional chime)
- Settings persist across restarts — duration, cycle, sound, pin state
- Session counter

## Development

Run from source:

```bash
git clone https://github.com/Shawnchee/claude-pomodoro.git
cd claude-pomodoro
npm install
npm start
```

### Building installers

```bash
npm run icon       # regenerate build/icon.png from assets/done.gif
npm run dist       # build all platforms
npm run dist:mac   # mac only
npm run dist:win   # windows only
npm run dist:linux # linux only
```

Output goes to `dist/`.

## Tech stack

- **macOS:** native [SwiftUI](https://developer.apple.com/xcode/swiftui/) app under `mac-native/`. Built with Swift Package Manager. Ships as a ~700KB `.app`.
- **Windows & Linux:** [Electron](https://www.electronjs.org/) + plain HTML/CSS/JS, packaged with [electron-builder](https://www.electron.build/). Ships as ~80–110MB installers.

Both builds render the same UI (cream + orange pixel-art, ~280×380 floating window) and ship from this repo on every `v*` tag push. macOS users can also install via the [Homebrew tap](https://github.com/Shawnchee/homebrew-claude-pomodoro).

## License

MIT
