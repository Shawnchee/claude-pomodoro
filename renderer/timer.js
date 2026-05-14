const timerEl = document.getElementById('timer');
const phaseEl = document.getElementById('phase');
const startBtn = document.getElementById('start');
const resetBtn = document.getElementById('reset');
const sessionsEl = document.getElementById('sessions');
const mascot = document.getElementById('mascot');
const pinBtn = document.getElementById('pin');
const durButtons = document.querySelectorAll('.dur-btn');
const durInput = document.getElementById('dur-custom');
const card = document.getElementById('card');
const settingsToggle = document.getElementById('settings-toggle');
const breakCustom = document.getElementById('break-custom');
const longCustom = document.getElementById('long-custom');
const cycleCustom = document.getElementById('cycle-custom');
const soundBtn = document.getElementById('sound-toggle');
const ding = document.getElementById('ding');

let settings = {
  workMinutes: 25,
  breakMinutes: 5,
  longBreakMinutes: 15,
  sessionsBeforeLongBreak: 4,
  soundEnabled: true,
  pinned: true,
};

let phase = 'work';
let nextBreakKind = 'break';
let secondsLeft = settings.workMinutes * 60;
let running = false;
let intervalId = null;
let sessions = 0;
let cycleCount = 0;

function format(s) {
  const m = Math.floor(s / 60).toString().padStart(2, '0');
  const r = (s % 60).toString().padStart(2, '0');
  return `${m}:${r}`;
}

function phaseLabel() {
  if (!running) return 'ready';
  if (phase === 'work') return 'focus';
  return nextBreakKind === 'long' ? 'long break' : 'break';
}

function render() {
  timerEl.textContent = format(secondsLeft);
  phaseEl.textContent = phaseLabel();
  startBtn.textContent = running ? 'pause' : 'start';
  mascot.src = running && phase === 'work' ? '../assets/work.gif' : '../assets/done.gif';
  durButtons.forEach((b) => (b.disabled = running));
  durInput.disabled = running;
}

function playDing() {
  if (!settings.soundEnabled) return;
  ding.currentTime = 0;
  ding.play().catch(() => {});
}

function tick() {
  secondsLeft -= 1;
  if (secondsLeft <= 0) {
    if (phase === 'work') {
      sessions += 1;
      cycleCount += 1;
      sessionsEl.textContent = sessions;
      const isLong = cycleCount >= settings.sessionsBeforeLongBreak;
      nextBreakKind = isLong ? 'long' : 'break';
      if (isLong) cycleCount = 0;
      phase = 'break';
      secondsLeft = (isLong ? settings.longBreakMinutes : settings.breakMinutes) * 60;
      playDing();
      window.api.notify('focus done', isLong ? 'time for a long break' : 'time for a break');
    } else {
      phase = 'work';
      secondsLeft = settings.workMinutes * 60;
      playDing();
      window.api.notify('break over', 'back to focus');
    }
  }
  render();
}

function start() {
  if (running) {
    running = false;
    clearInterval(intervalId);
  } else {
    running = true;
    intervalId = setInterval(tick, 1000);
  }
  render();
}

function reset() {
  running = false;
  clearInterval(intervalId);
  phase = 'work';
  secondsLeft = settings.workMinutes * 60;
  render();
}

function setWorkMinutes(min, fromPreset) {
  const clamped = Math.max(1, Math.min(180, Math.floor(min)));
  settings.workMinutes = clamped;
  window.api.setSetting('workMinutes', clamped);
  durButtons.forEach((b) => {
    b.classList.toggle('active', fromPreset && Number(b.dataset.min) === clamped);
  });
  if (!running && phase === 'work') {
    secondsLeft = clamped * 60;
  }
  render();
}

function applyPin(flag) {
  settings.pinned = flag;
  pinBtn.classList.toggle('pinned', flag);
  pinBtn.textContent = flag ? 'pinned' : 'pin';
  pinBtn.title = flag ? 'Currently always on top — click to unpin' : 'Click to pin always on top';
  window.api.setAlwaysOnTop(flag);
}

function togglePin() {
  applyPin(!settings.pinned);
  window.api.setSetting('pinned', settings.pinned);
}

function syncPresetActive(group, value) {
  document.querySelectorAll(`.set-btn[data-setting="${group}"]`).forEach((b) => {
    const v = group === 'cycle' ? Number(b.dataset.n) : Number(b.dataset.min);
    b.classList.toggle('active', v === value);
  });
}

function applyWorkPresetActive() {
  let matched = false;
  durButtons.forEach((b) => {
    const match = Number(b.dataset.min) === settings.workMinutes;
    b.classList.toggle('active', match);
    if (match) matched = true;
  });
  durInput.value = matched ? '' : String(settings.workMinutes);
}

function applyBreakPreset(value) {
  const clamped = Math.max(1, Math.min(60, Math.floor(value)));
  settings.breakMinutes = clamped;
  window.api.setSetting('breakMinutes', clamped);
  syncPresetActive('break', clamped);
  if (!running && phase === 'break' && nextBreakKind === 'break') {
    secondsLeft = clamped * 60;
  }
  render();
}

function applyLongPreset(value) {
  const clamped = Math.max(1, Math.min(60, Math.floor(value)));
  settings.longBreakMinutes = clamped;
  window.api.setSetting('longBreakMinutes', clamped);
  syncPresetActive('long', clamped);
  if (!running && phase === 'break' && nextBreakKind === 'long') {
    secondsLeft = clamped * 60;
  }
  render();
}

function applyCyclePreset(value) {
  const clamped = Math.max(1, Math.min(20, Math.floor(value)));
  settings.sessionsBeforeLongBreak = clamped;
  window.api.setSetting('sessionsBeforeLongBreak', clamped);
  syncPresetActive('cycle', clamped);
}

function applySoundToggle() {
  settings.soundEnabled = !settings.soundEnabled;
  window.api.setSetting('soundEnabled', settings.soundEnabled);
  soundBtn.textContent = settings.soundEnabled ? 'on' : 'off';
  soundBtn.classList.toggle('active', settings.soundEnabled);
}

function syncSettingsViewInputs() {
  syncPresetActive('break', settings.breakMinutes);
  syncPresetActive('long', settings.longBreakMinutes);
  syncPresetActive('cycle', settings.sessionsBeforeLongBreak);
  const breakPresets = [3, 5, 10];
  const longPresets = [10, 15, 20];
  const cyclePresets = [3, 4, 5];
  breakCustom.value = breakPresets.includes(settings.breakMinutes) ? '' : String(settings.breakMinutes);
  longCustom.value = longPresets.includes(settings.longBreakMinutes) ? '' : String(settings.longBreakMinutes);
  cycleCustom.value = cyclePresets.includes(settings.sessionsBeforeLongBreak) ? '' : String(settings.sessionsBeforeLongBreak);
  soundBtn.textContent = settings.soundEnabled ? 'on' : 'off';
  soundBtn.classList.toggle('active', settings.soundEnabled);
}

startBtn.addEventListener('click', start);
resetBtn.addEventListener('click', reset);
pinBtn.addEventListener('click', togglePin);

durButtons.forEach((btn) => {
  btn.addEventListener('click', () => {
    if (running) return;
    durInput.value = '';
    setWorkMinutes(Number(btn.dataset.min), true);
  });
});

durInput.addEventListener('input', () => {
  if (running) return;
  const v = Number(durInput.value);
  if (Number.isFinite(v) && v >= 1 && v <= 180) {
    setWorkMinutes(v, false);
  }
});

document.querySelectorAll('.set-btn[data-setting="break"]').forEach((b) => {
  b.addEventListener('click', () => {
    breakCustom.value = '';
    applyBreakPreset(Number(b.dataset.min));
  });
});

document.querySelectorAll('.set-btn[data-setting="long"]').forEach((b) => {
  b.addEventListener('click', () => {
    longCustom.value = '';
    applyLongPreset(Number(b.dataset.min));
  });
});

document.querySelectorAll('.set-btn[data-setting="cycle"]').forEach((b) => {
  b.addEventListener('click', () => {
    cycleCustom.value = '';
    applyCyclePreset(Number(b.dataset.n));
  });
});

breakCustom.addEventListener('input', () => {
  const v = Number(breakCustom.value);
  if (Number.isFinite(v) && v >= 1 && v <= 60) applyBreakPreset(v);
});

longCustom.addEventListener('input', () => {
  const v = Number(longCustom.value);
  if (Number.isFinite(v) && v >= 1 && v <= 60) applyLongPreset(v);
});

cycleCustom.addEventListener('input', () => {
  const v = Number(cycleCustom.value);
  if (Number.isFinite(v) && v >= 1 && v <= 20) applyCyclePreset(v);
});

soundBtn.addEventListener('click', applySoundToggle);

settingsToggle.addEventListener('click', () => {
  const opening = card.classList.contains('view-timer');
  card.classList.toggle('view-timer', !opening);
  card.classList.toggle('view-settings', opening);
  settingsToggle.classList.toggle('active', opening);
  if (opening) syncSettingsViewInputs();
});

document.getElementById('close').addEventListener('click', () => window.api.closeWindow());
document.getElementById('minimize').addEventListener('click', () => window.api.minimizeWindow());

(async () => {
  const loaded = await window.api.getSettings();
  settings = { ...settings, ...loaded };
  secondsLeft = settings.workMinutes * 60;
  applyPin(settings.pinned);
  applyWorkPresetActive();
  syncSettingsViewInputs();
  render();
})();
