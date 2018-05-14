// swift-tools-version:4.0
// Generated automatically by Perfect Assistant 2
// Date: 2018-05-14 00:59:57 +0000
import PackageDescription

let package = Package(
	name: "TILApp",
	dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
		.package(url: "https://github.com/BrettRToomey/Jobs.git", "1.0.0"..<"2.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-Notifications.git", "3.0.0"..<"4.0.0")
	],
	targets: [
		.target(name: "App", dependencies: ["FluentMySQL", "Vapor", "Leaf", "Authentication", "Jobs", "PerfectNotifications"]),
		.target(name: "Run", dependencies: ["App"]),
		.testTarget(name: "AppTests", dependencies: ["App"])
	]
)
