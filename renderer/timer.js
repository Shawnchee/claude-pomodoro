const WORK_SECONDS = 25 * 60;
const BREAK_SECONDS = 5 * 60;

const timerEl = document.getElementById('timer');
const phaseEl = document.getElementById('phase');
const startBtn = document.getElementById('start');
const resetBtn = document.getElementById('reset');
const sessionsEl = document.getElementById('sessions');
const mascot = document.getElementById('mascot');

let phase = 'work';
let secondsLeft = WORK_SECONDS;
let running = false;
let intervalId = null;
let sessions = 0;

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
      secondsLeft = WORK_SECONDS;
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
  secondsLeft = WORK_SECONDS;
  render();
}

startBtn.addEventListener('click', start);
resetBtn.addEventListener('click', reset);
document.getElementById('close').addEventListener('click', () => window.api?.closeWindow());
document.getElementById('minimize').addEventListener('click', () => window.api?.minimizeWindow());

render();
