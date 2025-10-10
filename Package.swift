// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OneFingerRotationGesture",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "OneFingerRotationGesture",
            targets: ["OneFingerRotationGesture"]),
    ],
    targets: [
        .target(
            name: "OneFingerRotationGesture",
            dependencies: [],
            path: "Sources/OneFingerRotationGesture"
        ),
        .testTarget(
            name: "OneFingerRotationGestureTests",
            dependencies: ["OneFingerRotationGesture"],
            path: "Tests/OneFingerRotationGestureTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

