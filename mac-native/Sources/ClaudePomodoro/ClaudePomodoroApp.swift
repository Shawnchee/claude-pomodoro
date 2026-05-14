import SwiftUI
import UserNotifications
import AppKit

@main
struct ClaudePomodoroApp: App {
    @StateObject private var model: TimerModel

    init() {
        let m = TimerModel()
        _model = StateObject(wrappedValue: m)
        // UNUserNotificationCenter requires a real .app bundle. Skip when running
        // the bare executable via `swift run` (Bundle.main has no bundleIdentifier).
        if Bundle.main.bundleIdentifier != nil {
            UNUserNotificationCenter.current().delegate = m
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .frame(width: 280, height: 380)
                .background(WindowConfigurator(pinned: model.pinned))
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

struct WindowConfigurator: NSViewRepresentable {
    let pinned: Bool

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            configure(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        configure(nsView.window)
    }

    private func configure(_ window: NSWindow?) {
        guard let window else { return }
        window.styleMask = [.borderless]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.level = pinned ? .floating : .normal

        let size = NSSize(width: 280, height: 380)
        window.setContentSize(size)
        window.minSize = size
        window.maxSize = size
    }
}
