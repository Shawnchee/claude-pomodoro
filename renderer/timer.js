const BREAK_SECONDS = 5 * 60;

const timerEl = document.getElementById('timer');
const phaseEl = document.getElementById('phase');
const startBtn = document.getElementById('start');
const resetBtn = document.getElementById('reset');
const sessionsEl = document.getElementById('sessions');
const mascot = document.getElementById('mascot');
const pinBtn = document.getElementById('pin');
const durButtons = document.querySelectorAll('.dur-btn');
const durInput = document.getElementById('dur-custom');

let workSeconds = 25 * 60;
let phase = 'work';
let secondsLeft = workSeconds;
let running = false;
let intervalId = null;
let sessions = 0;
let pinned = true;

function format(s) {
  const m = Math.floor(s / 60).toString().padStart(2, '0');
  const r = (s % 60).toString().padStart(2, '0');
  return `${m}:${r}`;
}

function render() {
  timerEl.textContent = format(secondsLeft);
  phaseEl.textContent = running ? (phase === 'work' ? 'focus' : 'break') : 'ready';
  startBtn.textContent = running ? 'pause' : 'start';
  mascot.src = running && phase === 'work' ? '../assets/work.gif' : '../assets/done.gif';
  durButtons.forEach((b) => (b.disabled = running));
  durInput.disabled = running;
}

function tick() {
  secondsLeft -= 1;
  if (secondsLeft <= 0) {
    if (phase === 'work') {
      sessions += 1;
      sessionsEl.textContent = sessions;
      phase = 'break';
      secondsLeft = BREAK_SECONDS;
      window.api?.notify('focus done', 'time for a break');
    } else {
      phase = 'work';
      secondsLeft = workSeconds;
      window.api?.notify('break over', 'back to focus');
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
  secondsLeft = workSeconds;
  render();
}

function setWorkMinutes(min, fromPreset) {
  const clamped = Math.max(1, Math.min(180, Math.floor(min)));
  workSeconds = clamped * 60;
  durButtons.forEach((b) => {
    b.classList.toggle('active', fromPreset && Number(b.dataset.min) === clamped);
  });
  if (!running && phase === 'work') {
    secondsLeft = workSeconds;
  }
  render();
}

function togglePin() {
  pinned = !pinned;
  pinBtn.classList.toggle('pinned', pinned);
  pinBtn.textContent = pinned ? 'pinned' : 'pin';
  pinBtn.title = pinned ? 'Currently always on top — click to unpin' : 'Click to pin always on top';
  window.api?.setAlwaysOnTop(pinned);
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

document.getElementById('close').addEventListener('click', () => window.api?.closeWindow());
document.getElementById('minimize').addEventListener('click', () => window.api?.minimizeWindow());

render();
