# Contributing

Small personal project — contributions welcome, light-touch process.

## Dev setup

```bash
git clone https://github.com/Shawnchee/claude-pomodoro.git
cd claude-pomodoro
npm install
npm start
```

## Project layout

| Path | What lives there |
| ---- | ---------------- |
| `main.js` | Electron main process — window config, IPC handlers |
| `preload.js` | Context-bridge between main and renderer |
| `renderer/` | UI: `index.html`, `style.css`, `timer.js` (no framework) |
| `assets/` | Mascot gifs (`work.gif`, `done.gif`) |
| `build/` | App icon and electron-builder resources |
| `scripts/` | Helper scripts (icon generation) |
| `.github/workflows/` | CI release workflow |

## Commits

- One logical change per commit.
- Conventional-commit prefixes: `feat:`, `fix:`, `docs:`, `chore:`, `ci:`, `refactor:`.
- Imperative mood, lowercase subject, ≤ 72 chars. Body explains the *why*.
- No `Co-Authored-By:` trailers.
- No emojis anywhere — code, commits, or docs.

## PRs

1. Fork the repo, branch off `master`.
2. One feature or fix per PR — keep the diff focused.
3. Run `npm start` and exercise the changed path before submitting. For UI changes, attach a screenshot or short GIF to the PR description.
4. Open the PR against `master`.

## Building installers

```bash
npm run dist        # current host platform
npm run dist:mac    # macOS arm64 dmg
npm run dist:win    # windows nsis (needs windows or wine)
npm run dist:linux  # linux x64 appimage
```

Output lands in `dist/`. Cross-platform releases are easier via the GitHub Actions workflow at `.github/workflows/release.yml` — push a `v*` tag and CI builds all three in parallel.

## Style guidelines

- No frontend framework — plain HTML/CSS/JS keeps the renderer ~100 lines.
- Keep the window single-purpose. New features that need a settings panel should fit in the existing card; if they don't, discuss in an issue first.
- Security: don't enable `nodeIntegration`, don't disable `contextIsolation`, don't relax the CSP. Anything that needs main-process power goes through `preload.js`.
- All asset gifs go in `assets/` and must be transparent-background pixel art that matches the existing mascot palette (cream `#fdf6ec`, orange `#d97757`).

## License

By contributing you agree your work is released under the project's [MIT license](LICENSE).
