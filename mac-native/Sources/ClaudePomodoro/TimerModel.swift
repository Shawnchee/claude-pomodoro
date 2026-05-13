import Foundation
import UserNotifications

enum Phase {
    case work
    case breakTime
}

@MainActor
final class TimerModel: ObservableObject {
    @Published var workSeconds: Int = 25 * 60
    @Published var secondsLeft: Int = 25 * 60
    @Published var phase: Phase = .work
    @Published var running: Bool = false
    @Published var sessions: Int = 0
    @Published var pinned: Bool = true
    @Published var selectedPreset: Int? = 25

    private var timer: Timer?
    let breakSeconds: Int = 5 * 60

    var formatted: String {
        let m = secondsLeft / 60
        let s = secondsLeft % 60
        return String(format: "%02d:%02d", m, s)
    }

    var phaseLabel: String {
        if !running { return "ready" }
        return phase == .work ? "focus" : "break"
    }

    var mascotName: String {
        (running && phase == .work) ? "work" : "done"
    }

    func toggle() {
        if running {
            stop()
        } else {
            running = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                Task { @MainActor in self?.tick() }
            }
        }
    }

    func reset() {
        stop()
        phase = .work
        secondsLeft = workSeconds
    }

    func setWorkMinutes(_ min: Int, fromPreset: Bool) {
        let clamped = max(1, Swift.min(180, min))
        workSeconds = clamped * 60
        selectedPreset = fromPreset ? clamped : nil
        if !running && phase == .work {
            secondsLeft = workSeconds
        }
    }

    func togglePin() {
        pinned.toggle()
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
        running = false
    }

    private func tick() {
        secondsLeft -= 1
        if secondsLeft <= 0 {
            if phase == .work {
                sessions += 1
                phase = .breakTime
                secondsLeft = breakSeconds
                notify(title: "focus done", body: "time for a break")
            } else {
                phase = .work
                secondsLeft = workSeconds
                notify(title: "break over", body: "back to focus")
            }
        }
    }

    private func notify(title: String, body: String) {
        // Skip when there is no .app bundle (e.g. running via `swift run`).
        // UNUserNotificationCenter.current() will crash otherwise.
        guard Bundle.main.bundleIdentifier != nil else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
