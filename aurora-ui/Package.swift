// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AuroraUI",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "AuroraUI",
            targets: ["AuroraUI"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AuroraBridge",
            dependencies: [],
            path: "Sources/AuroraBridge",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("../../aurora/include"),
            ],
            linkerSettings: [
                .linkedLibrary("aurora_kernel", .when(platforms: [.macOS])),
                .unsafeFlags(["-L../../aurora/build/lib"], .when(platforms: [.macOS]))
            ]
        ),
        .executableTarget(
            name: "AuroraUI",
            dependencies: ["AuroraBridge"],
            path: "Sources/AuroraUI",
            swiftSettings: [
                .unsafeFlags(["-I", "../../aurora/include"])
            ]
        ),
    ]
)
