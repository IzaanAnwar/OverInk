// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "OverInk",
  platforms: [.macOS(.v26)],
  products: [
    .executable(name: "OverInk", targets: ["OverInk"])
  ],
  targets: [
    .executableTarget(name: "OverInk"),
    .testTarget(name: "OverInkTests", dependencies: ["OverInk"]),
  ]
)
