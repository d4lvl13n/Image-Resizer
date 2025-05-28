// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ImageBatchWebPConverter",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ImageBatchWebPConverter",
            targets: ["ImageBatchWebPConverter"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Models",
            dependencies: [],
            path: "Sources/ImageBatchWebPConverter/Models"
        ),
        .target(
            name: "Utils",
            dependencies: ["Models"],
            path: "Sources/ImageBatchWebPConverter/Utils"
        ),
        .target(
            name: "Components",
            dependencies: ["Utils", "Models"],
            path: "Sources/ImageBatchWebPConverter/Components"
        ),
        .executableTarget(
            name: "ImageBatchWebPConverter",
            dependencies: ["Models", "Utils", "Components"],
            path: "Sources/ImageBatchWebPConverter",
            exclude: ["Models", "Utils", "Components", "Resources/Info.plist"],
            resources: [
                .copy("Resources/cwebp"),
                .copy("Resources/AppIcon.icns")
            ]
        )
    ]
) 