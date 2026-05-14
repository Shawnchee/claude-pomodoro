import Foundation

// SPM's generated `Bundle.module` only checks one path:
//   Bundle.main.bundleURL/ClaudePomodoro_ClaudePomodoro.bundle
//
// For a packaged .app that's the .app root, which conflicts with macOS
// codesign — codesign refuses to sign a .app that has un-sealed content
// outside Contents/. We need the resource bundle to live under
// Contents/Resources/ instead, so we override the lookup with our own.
enum BundleResources {
    static let bundle: Bundle = {
        let candidates: [URL] = [
            Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/ClaudePomodoro_ClaudePomodoro.bundle"),
            Bundle.main.bundleURL.appendingPathComponent("ClaudePomodoro_ClaudePomodoro.bundle"),
        ]
        for url in candidates {
            if let b = Bundle(url: url) {
                return b
            }
        }
        return .module
    }()

    static func url(forResource name: String, withExtension ext: String) -> URL? {
        bundle.url(forResource: name, withExtension: ext)
    }
}
