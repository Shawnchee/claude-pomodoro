import SwiftUI
import AppKit

struct AnimatedGIFView: NSViewRepresentable {
    let name: String

    func makeNSView(context: Context) -> NSImageView {
        let view = FlexibleImageView()
        view.imageScaling = .scaleProportionallyUpOrDown
        view.animates = true
        view.image = loadImage()
        view.wantsLayer = true
        view.layer?.magnificationFilter = .nearest
        view.layer?.minificationFilter = .nearest
        return view
    }

    func updateNSView(_ nsView: NSImageView, context: Context) {
        nsView.image = loadImage()
        nsView.animates = true
    }

    private func loadImage() -> NSImage? {
        guard let url = Self.resourceBundle.url(forResource: name, withExtension: "gif") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }

    // SPM's generated `Bundle.module` only checks one path:
    //   Bundle.main.bundleURL/ClaudePomodoro_ClaudePomodoro.bundle
    //
    // For a packaged .app that's the .app root, which conflicts with macOS
    // codesign — codesign refuses to sign a .app that has un-sealed content
    // outside Contents/. We need the resource bundle to live under
    // Contents/Resources/ instead, so we override the lookup with our own:
    // try Contents/Resources/ first, then the .app root (SPM default), then
    // fall back to Bundle.module for `swift run` / SPM-internal builds.
    private static let resourceBundle: Bundle = {
        let candidates: [URL] = [
            Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/ClaudePomodoro_ClaudePomodoro.bundle"),
            Bundle.main.bundleURL.appendingPathComponent("ClaudePomodoro_ClaudePomodoro.bundle"),
        ]
        for url in candidates {
            if let bundle = Bundle(url: url) {
                return bundle
            }
        }
        return .module
    }()
}

private final class FlexibleImageView: NSImageView {
    override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }
}
