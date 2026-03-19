// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "preload_google_ads",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "preload-google-ads", targets: ["preload_google_ads"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "preload_google_ads",
            dependencies: [],
            path: "Classes",
            publicHeadersPath: ""
        )
    ]
)
