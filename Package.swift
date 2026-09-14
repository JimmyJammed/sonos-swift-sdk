// swift-tools-version: 6.3
import PackageDescription
let package = Package(name: "SonosSDK", platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "SonosSDK", targets: ["SonosSDK"]), .library(name: "SonosSDKUI", targets: ["SonosSDKUI"])],
    dependencies: [.package(url: "https://github.com/JimmyJammed/sonos-swift-networking.git", revision: "cc68f4e76dfcd7bc7ec8e97e432e90834f5596f9")],
    targets: [.target(name: "SonosSDK", dependencies: [.product(name: "SonosNetworking", package: "sonos-swift-networking")]),
              .target(name: "SonosSDKUI", dependencies: ["SonosSDK"]),
              .testTarget(name: "SonosSDKTests", dependencies: ["SonosSDK"])], swiftLanguageModes: [.v6])
