const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  closeWindow: () => ipcRenderer.send('window:close'),
  minimizeWindow: () => ipcRenderer.send('window:minimize'),
  setAlwaysOnTop: (flag) => ipcRenderer.send('window:setAlwaysOnTop', flag),
  notify: (title, body) => ipcRenderer.send('notify', { title, body }),
});
