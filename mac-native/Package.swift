// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClaudePomodoro",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ClaudePomodoro",
            resources: [
                .copy("Resources/work.gif"),
                .copy("Resources/done.gif")
            ]
        )
    ]
)
