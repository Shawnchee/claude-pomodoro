import Foundation
import UserNotifications
import AVFoundation
import AppKit

enum Phase {
    case work
    case breakTime
    case longBreak
}

private enum Keys {
    static let workMinutes = "workMinutes"
    static let breakMinutes = "breakMinutes"
    static let longBreakMinutes = "longBreakMinutes"
    static let sessionsBeforeLongBreak = "sessionsBeforeLongBreak"
    static let soundEnabled = "soundEnabled"
    static let pinned = "pinned"
}

@MainActor
final class TimerModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var workMinutes: Int {
        didSet {
            UserDefaults.standard.set(workMinutes, forKey: Keys.workMinutes)
            if !running && phase == .work {
                secondsLeft = workMinutes * 60
            }
        }
    }
    @Published var breakMinutes: Int {
        didSet {
            UserDefaults.standard.set(breakMinutes, forKey: Keys.breakMinutes)
            if !running && phase == .breakTime {
                secondsLeft = breakMinutes * 60
            }
        }
    }
    @Published var longBreakMinutes: Int {
        didSet {
            UserDefaults.standard.set(longBreakMinutes, forKey: Keys.longBreakMinutes)
            if !running && phase == .longBreak {
                secondsLeft = longBreakMinutes * 60
            }
        }
    }
    @Published var sessionsBeforeLongBreak: Int {
        didSet { UserDefaults.standard.set(sessionsBeforeLongBreak, forKey: Keys.sessionsBeforeLongBreak) }
    }
    @Published var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: Keys.soundEnabled) }
    }
    @Published var pinned: Bool {
        didSet { UserDefaults.standard.set(pinned, forKey: Keys.pinned) }
    }

    @Published var secondsLeft: Int
    @Published var phase: Phase = .work
    @Published var running: Bool = false
    @Published var sessions: Int = 0
    @Published var selectedPreset: Int?

    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    private var cycleCount: Int = 0

    override init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            Keys.workMinutes: 25,
            Keys.breakMinutes: 5,
            Keys.longBreakMinutes: 15,
            Keys.sessionsBeforeLongBreak: 4,
            Keys.soundEnabled: true,
            Keys.pinned: true,
        ])
        let work = defaults.integer(forKey: Keys.workMinutes)
        self.workMinutes = work
        self.breakMinutes = defaults.integer(forKey: Keys.breakMinutes)
        self.longBreakMinutes = defaults.integer(forKey: Keys.longBreakMinutes)
        self.sessionsBeforeLongBreak = defaults.integer(forKey: Keys.sessionsBeforeLongBreak)
        self.soundEnabled = defaults.bool(forKey: Keys.soundEnabled)
        self.pinned = defaults.bool(forKey: Keys.pinned)
        self.secondsLeft = work * 60
        self.selectedPreset = [5, 15, 25].contains(work) ? work : nil
        super.init()
    }

    var formatted: String {
        let m = secondsLeft / 60
        let s = secondsLeft % 60
        return String(format: "%02d:%02d", m, s)
    }

    var phaseLabel: String {
        if !running { return "ready" }
        switch phase {
        case .work: return "focus"
        case .breakTime: return "break"
        case .longBreak: return "long break"
        }
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
        secondsLeft = workMinutes * 60
    }

    func setWorkMinutes(_ min: Int, fromPreset: Bool) {
        let clamped = max(1, Swift.min(180, min))
        workMinutes = clamped
        selectedPreset = fromPreset ? clamped : nil
    }

    func setBreakMinutes(_ min: Int) {
        breakMinutes = max(1, Swift.min(60, min))
    }

    func setLongBreakMinutes(_ min: Int) {
        longBreakMinutes = max(1, Swift.min(60, min))
    }

    func setSessionsBeforeLongBreak(_ n: Int) {
        sessionsBeforeLongBreak = max(1, Swift.min(20, n))
    }

    func togglePin() {
        pinned.toggle()
    }

    func toggleSound() {
        soundEnabled.toggle()
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
        running = false
    }

    private func tick() {
        secondsLeft -= 1
        if secondsLeft <= 0 {
            advancePhase()
        }
    }

    private func advancePhase() {
        switch phase {
        case .work:
            sessions += 1
            cycleCount += 1
            if cycleCount >= sessionsBeforeLongBreak {
                cycleCount = 0
                phase = .longBreak
                secondsLeft = longBreakMinutes * 60
                playDing()
                notify(title: "focus done", body: "time for a long break")
            } else {
                phase = .breakTime
                secondsLeft = breakMinutes * 60
                playDing()
                notify(title: "focus done", body: "time for a break")
            }
        case .breakTime, .longBreak:
            phase = .work
            secondsLeft = workMinutes * 60
            playDing()
            notify(title: "break over", body: "back to focus")
        }
    }

    private func playDing() {
        guard soundEnabled else { return }
        guard let url = BundleResources.url(forResource: "celebratory", withExtension: "wav") else { return }
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()
    }

    private func notify(title: String, body: String) {
        // Skip when there is no .app bundle (e.g. running via `swift run`).
        // UNUserNotificationCenter.current() will crash otherwise.
        guard Bundle.main.bundleIdentifier != nil else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = soundEnabled ? .default : nil
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}
