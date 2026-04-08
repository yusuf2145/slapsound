// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SlapSound",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "SlapSound",
            path: "Sources/SlapSound",
            resources: [
                .copy("Resources/Sounds"),
                .copy("Resources/AppIcon.icns")
            ],
            linkerSettings: [
                .linkedFramework("IOKit"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("AppKit"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("Speech"),
            ]
        )
    ]
)
