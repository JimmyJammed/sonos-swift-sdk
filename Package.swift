// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SonosSDK",
    platforms: [.iOS(.v14),
                .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SonosSDK",
            targets: ["SonosSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "SonosNetworking", url: "https://github.com/MiaShopgal/sonos-swift-networking.git", .branch("setPlayback")),
        .package(url: "https://github.com/stleamist/BetterSafariView.git", .upToNextMajor(from: "2.3.1")),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.7.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
        .package(url: "https://github.com/realm/SwiftLint.git", .upToNextMajor(from: "0.43.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SonosSDK",
            dependencies: [
                "SonosNetworking",
                "BetterSafariView",
                "Swinject",
                "SwiftyJSON"
            ]),
        .testTarget(
            name: "SonosSDKTests",
            dependencies: ["SonosSDK"]),
    ]
)
