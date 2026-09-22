// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "GlassPen",
  platforms: [.macOS(.v26)],
  products: [
    .executable(name: "GlassPen", targets: ["GlassPen"])
  ],
  targets: [
    .executableTarget(name: "GlassPen"),
    .testTarget(name: "GlassPenTests", dependencies: ["GlassPen"]),
  ]
)
