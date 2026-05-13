# 🍅 Claude Pomodoro

A cute pixel-art pomodoro timer that lives in a floating always-on-top window. Cross-platform: **macOS · Windows · Linux**.

<p align="center">
  <img src="build/icon.png" alt="Claude Pomodoro icon" width="160" />
</p>

## Download

Grab the latest installer for your OS from the [Releases page](https://github.com/Shawnchee/claude-pomodoro/releases/latest):

| OS      | File                            | How to install |
| ------- | ------------------------------- | -------------- |
| macOS   | `Claude-Pomodoro-*.dmg`         | Open the `.dmg`, drag the app to **Applications** |
| Windows | `Claude-Pomodoro-Setup-*.exe`   | Run the installer, follow the wizard |
| Linux   | `Claude-Pomodoro-*.AppImage`    | `chmod +x` the file, then double-click |

### First-launch warnings (unsigned app)

Because the app isn't code-signed yet, your OS will show a one-time security dialog. This is normal for indie apps; here's how to get past it:

- **macOS:** right-click the app → **Open** → confirm in the dialog. After the first run it'll open normally.
- **Windows:** click **More info** → **Run anyway** on the SmartScreen screen.
- **Linux:** no warning, just runs.

## Features (v0.1)

- 25-minute focus / 5-minute break cycles
- Start / pause / reset
- Always-on-top floating window (drag from the title bar)
- Pixel-art mascot — hammers during focus, idles during break
- Native OS notifications when phases switch
- Session counter

## Development

If you want to hack on it or build from source:

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
