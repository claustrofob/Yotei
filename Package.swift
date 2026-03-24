// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Yotei",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Yotei",
            targets: ["Yotei"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/claustrofob/Eventually.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Yotei"
        ),
    ]
)

