// swift-tools-version: 5.8

import PackageDescription

let package: Package = Package(
    name: "EncoreApi",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.122.0")),
        .package(url: "https://github.com/vapor/fluent.git", .upToNextMajor(from: "4.13.0")),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", .upToNextMajor(from: "2.12.0")),
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", .upToNextMajor(from: "4.8.0")),
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.101.3"))
    ],
    targets: [
        .executableTarget(
            name: "EncoreApi",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "FluentMySQLDriver", package: "fluent-mysql-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "EncoreApiTests",
            dependencies: [
                .target(name: "EncoreApi"),
                .product(name: "VaporTesting", package: "vapor")
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("ImmutableWeakCaptures")
    ]
}
