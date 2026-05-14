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
        guard let url = BundleResources.url(forResource: name, withExtension: "gif") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }
}

private final class FlexibleImageView: NSImageView {
    override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }
}
