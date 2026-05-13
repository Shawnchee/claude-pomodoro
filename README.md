# Claude Pomodoro

A cute pixel-art pomodoro timer that lives in a floating always-on-top window. Cross-platform: macOS, Windows, Linux.

<p align="center">
  <img src="build/icon.png" alt="Claude Pomodoro icon" width="160" />
</p>

## Download

All installers live on the [Releases page](https://github.com/Shawnchee/claude-pomodoro/releases/latest). The app is unsigned on every platform, so expect a one-time security warning on first launch — workarounds are inline below.

### macOS

Download `Claude Pomodoro-0.1.0-arm64.dmg` from the Releases page.

> Apple Silicon (M1/M2/M3/M4) only. Intel Macs can run it under Rosetta or wait for a future universal build.

1. Open the `.dmg`.
2. Drag **Claude Pomodoro** into **Applications**.
3. Launch it the first time by right-clicking the app in Applications and choosing **Open**, then confirm in the dialog. After that it opens normally from Launchpad/Spotlight.

If you double-click instead and see *"Apple could not verify… is free of malware"*, dismiss it and use the right-click → Open path above.

### Windows

Download `Claude-Pomodoro-Setup-0.1.0.exe` from the Releases page (x64).

1. Run the installer.
2. When Windows SmartScreen shows *"Windows protected your PC"*, click **More info** → **Run anyway**.
3. Follow the installer wizard.

The app will appear in your Start menu as **Claude Pomodoro**.

### Linux

Download `Claude Pomodoro-0.1.0.AppImage` from the Releases page (x64).

```bash
chmod +x "Claude Pomodoro-0.1.0.AppImage"
./"Claude Pomodoro-0.1.0.AppImage"
```

No security prompt — AppImages run as the executing user. To integrate it into your application menu, use a tool like [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher).

## Features (v0.1)

- 25-minute focus / 5-minute break cycles
- Start / pause / reset
- Always-on-top floating window (drag from the title bar)
- Pixel-art mascot — hammers during focus, idles during break
- Native OS notifications when phases switch
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

[Electron](https://www.electronjs.org/) + plain HTML/CSS/JS, packaged with [electron-builder](https://www.electron.build/).

## License

MIT
