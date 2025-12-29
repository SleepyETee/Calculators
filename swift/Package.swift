// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Calculator",
    targets: [
        .executableTarget(
            name: "Calculator",
            path: "Sources"
        )
    ]
)
