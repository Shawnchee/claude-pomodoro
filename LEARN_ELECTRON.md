# Electron — A Developer's Field Guide

> A practical primer pegged to the `claude-pomodoro` project you just built.

---

## 1. What Electron actually is

**Electron is not a language.** It's a runtime / framework that bundles two things into a single executable:

1. **Chromium** — the same browser engine as Chrome. Renders your UI.
2. **Node.js** — the JS runtime. Gives you filesystem, networking, native OS APIs.

You write your app in **HTML, CSS, and JavaScript** (the same skills as a web developer), and Electron wraps it into a `.app` (macOS), `.exe` (Windows), or `.AppImage`/`.deb` (Linux).

> **Mental model:** Electron = "Chrome that also has Node, packaged as a desktop app."

Famous Electron apps: VS Code, Slack, Discord, Figma desktop, Notion, 1Password, GitHub Desktop, Postman.

---

## 2. The two-process model (the most important concept)

Electron splits your app into **two kinds of processes**:

### Main process (`main.js`)
- **One per app.** Runs in Node.js.
- Owns the lifecycle: creates windows, handles app menus, listens for OS events.
- Has full access to Node APIs (`fs`, `path`, native modules).
- Cannot touch the DOM directly — it has no UI.

### Renderer process (your HTML page)
- **One per window.** Runs in Chromium.
- This is where your `index.html`, `style.css`, `timer.js` live.
- By default, **does NOT** have Node access (for security — your renderer is essentially a sandboxed web page).
- Talks to the main process via **IPC** (inter-process communication).

In your pomodoro project:
- `main.js` = main process (creates the floating window, shows notifications)
- `renderer/*` = renderer process (the timer UI you click)
- `preload.js` = the safe bridge between them

```
┌─────────────────────────┐         ┌──────────────────────────┐
│  Main process           │   IPC   │  Renderer process        │
│  (Node + Electron API)  │ ◄─────► │  (Chromium + your HTML)  │
│  main.js                │         │  renderer/index.html     │
└─────────────────────────┘         └──────────────────────────┘
                                              ▲
                                              │ preload.js
                                              │ (safe bridge)
```

---

## 3. The preload script — why it exists

The renderer cannot import `electron` directly (would be a security hole — any XSS in your page becomes RCE on the host machine).

The **preload script** runs in the renderer context but with Node access, and uses `contextBridge` to expose *only the specific functions you choose* on `window.api`.

In your project, `preload.js` does this:

```js
contextBridge.exposeInMainWorld('api', {
  closeWindow: () => ipcRenderer.send('window:close'),
  notify: (title, body) => ipcRenderer.send('notify', { title, body }),
});
```

Then `timer.js` calls `window.api.notify(...)` — it has no idea what `ipcRenderer` is. Clean separation.

**Rule of thumb:** keep `contextIsolation: true` and `nodeIntegration: false`. Only expose what you need.

---

## 4. IPC patterns

Three patterns you'll use constantly:

| Pattern             | Direction              | Use case                          |
| ------------------- | ---------------------- | --------------------------------- |
| `ipcRenderer.send`  | Renderer → Main (fire-and-forget) | "close this window" |
| `ipcRenderer.invoke` + `ipcMain.handle` | Renderer → Main (with reply) | "read this file, give me contents" |
| `webContents.send`  | Main → Renderer        | "the timer hit zero, update UI"   |

Your project only needed the first one. Most simple apps do.

---

## 5. Window options you'll touch a lot

From `main.js`:

```js
new BrowserWindow({
  width: 280, height: 380,
  frame: false,         // remove the OS titlebar
  transparent: true,    // makes the bg transparent (so border-radius works)
  alwaysOnTop: true,    // floats above other apps
  resizable: false,
  webPreferences: {
    preload: path.join(__dirname, 'preload.js'),
    contextIsolation: true,   // security
    nodeIntegration: false,   // security
  },
})
```

Other ones worth knowing:
- `transparent: true` — let CSS handle the chrome. Combine with `frame: false`.
- `vibrancy: 'under-window'` (macOS only) — frosted glass effect.
- `titleBarStyle: 'hidden'` — keep traffic lights on Mac, hide the bar.
- `show: false` — create hidden, then `mainWindow.show()` once ready (avoids flash).

---

## 6. Drag regions in frameless windows

When you set `frame: false`, you lose the OS titlebar — so you can't drag the window. Fix it in CSS:

```css
.titlebar { -webkit-app-region: drag; }   /* this area drags the window */
.button   { -webkit-app-region: no-drag; } /* but buttons still click */
```

This is the exact trick your pomodoro uses on the `.titlebar` div.

---

## 7. Lifecycle events you'll see in every app

```js
app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  // On macOS, apps usually stay alive even with no windows
  if (process.platform !== 'darwin') app.quit();
});

app.on('activate', () => {
  // macOS: reopen window when dock icon clicked
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});
```

These three blocks are the standard cross-platform incantation. Copy-paste-keep.

---

## 8. Security checklist (read before shipping anything)

1. ✅ `contextIsolation: true`
2. ✅ `nodeIntegration: false`
3. ✅ Use a `preload.js` with `contextBridge`, never expose `ipcRenderer` directly
4. ✅ Add a Content-Security-Policy `<meta>` tag in your HTML
5. ✅ Validate all data sent over IPC (treat the renderer as untrusted)
6. ❌ Never `eval()` user input
7. ❌ Never load remote URLs into a window with Node access

Your pomodoro app already does 1–4.

---

## 9. Packaging for distribution

`npm start` is for development. To ship, use one of:

- **electron-builder** — most popular, produces `.dmg`, `.exe`, `.AppImage`, auto-updater support.
- **electron-forge** — official Electron tool, batteries included.

Quick start with electron-builder:

```bash
npm install --save-dev electron-builder
```

Add to `package.json`:

```json
"scripts": {
  "dist": "electron-builder"
},
"build": {
  "appId": "com.shawnchee.claudepomodoro",
  "mac": { "target": "dmg" },
  "win": { "target": "nsis" },
  "linux": { "target": "AppImage" }
}
```

Then `npm run dist`. Code signing (for macOS notarization, Windows SmartScreen) is a separate rabbit hole.

---

## 10. Honest tradeoffs

**Pros**
- Write once, run on three OSes
- Use the entire npm ecosystem
- Web devs are productive immediately
- Native menus, notifications, tray icons, file dialogs all available

**Cons**
- **Heavy.** Every Electron app bundles its own ~80MB Chromium. Ten Electron apps = ten copies.
- **RAM hungry.** Each window is a Chromium tab.
- **Not "native"** — your buttons are HTML, not Cocoa/Win32. Looks like a web app, feels like a web app.

### Alternatives, ranked by maturity

| Tool          | Bundle size | Language     | Notes                                    |
| ------------- | ----------- | ------------ | ---------------------------------------- |
| **Electron**  | ~80MB       | JS/HTML/CSS  | Battle-tested, biggest community         |
| **Tauri**     | ~5MB        | Rust + JS UI | Uses OS's webview instead of bundling Chromium. Smaller, faster, but Rust required for backend |
| **Wails**     | ~10MB       | Go + JS UI   | Like Tauri but Go                        |
| **Neutralino**| ~2MB        | JS only      | Tiny, less mature                        |
| **Flutter**   | ~30MB       | Dart         | Fully native rendering, not web-based    |

**When to pick Electron over Tauri:** team is JS-only, you want maximum ecosystem support, bundle size doesn't matter, you need deep Chrome features (DevTools, specific Chromium APIs).

**When to pick Tauri:** you care about size/perf, you have any Rust appetite, you're building something many people will install.

---

## 11. What to read next

1. **[Electron docs — Quick Start](https://www.electronjs.org/docs/latest/tutorial/quick-start)** — official, well written.
2. **[Process Model](https://www.electronjs.org/docs/latest/tutorial/process-model)** — make sure the main/renderer split clicks before you build anything bigger.
3. **[Security checklist](https://www.electronjs.org/docs/latest/tutorial/security)** — read it once, refer back later.
4. **[electron/electron repo](https://github.com/electron/electron)** — issues and discussions often beat StackOverflow.

---

## 12. Things you can now do to your pomodoro project to learn more

In rough order of difficulty:

1. Add a tray icon that shows the remaining time in the menu bar.
2. Persist session count across restarts (use `electron-store` or write a JSON file via `app.getPath('userData')`).
3. Make work/break durations configurable in a settings window (second BrowserWindow).
4. Add a global shortcut (e.g. `Cmd+Shift+P` to start/pause from anywhere) via `globalShortcut`.
5. Package and distribute it with `electron-builder`.
6. Add auto-update via `electron-updater`.

Each one teaches a different Electron API. The pomodoro is a perfect sandbox — small enough that nothing snowballs.
