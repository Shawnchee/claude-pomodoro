const { app, BrowserWindow } = require('electron');
const fs = require('fs');
const path = require('path');

app.whenReady().then(async () => {
  const win = new BrowserWindow({
    width: 1024,
    height: 1024,
    show: false,
    transparent: true,
    frame: false,
    webPreferences: { offscreen: false },
  });

  await win.loadFile(path.join(__dirname, '..', 'build', 'make-icon.html'));

  for (let i = 0; i < 50; i++) {
    const ready = await win.webContents.executeJavaScript('window._ready === true');
    if (ready) break;
    await new Promise((r) => setTimeout(r, 100));
  }

  const dataUrl = await win.webContents.executeJavaScript(
    "document.getElementById('c').toDataURL('image/png')"
  );

  const base64 = dataUrl.replace(/^data:image\/png;base64,/, '');
  const out = path.join(__dirname, '..', 'build', 'icon.png');
  fs.writeFileSync(out, Buffer.from(base64, 'base64'));
  console.log('icon saved →', out);

  app.quit();
});
