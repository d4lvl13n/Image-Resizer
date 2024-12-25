// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ImageBatchWebPConverter",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "ImageBatchWebPConverter", targets: ["ImageBatchWebPConverter"])
    ],
    targets: [
        .executableTarget(
            name: "ImageBatchWebPConverter",
            path: "Sources/ImageBatchWebPConverter",
            resources: [
                .copy("Resources/cwebp")
            ]
        )
    ]
) 