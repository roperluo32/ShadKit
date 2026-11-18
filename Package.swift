// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShadKit",
    // Package minimums. Only `ShadcnUI` is supported on watchOS today —
    // watch apps should depend on that product alone. Other libraries still
    // target macOS / iOS and are not watch-ready.
    platforms: [.macOS(.v14), .iOS(.v17), .watchOS(.v10)],
    products: [
        // Design tokens + the shadcn/ui primitive set. (macOS / iOS / watchOS)
        .library(name: "ShadcnUI", targets: ["ShadcnUI"]),
        // Vercel AI Elements, ported on top of ShadcnUI. (macOS / iOS)
        .library(name: "AIElementsUI", targets: ["AIElementsUI"]),
        // Node-graph canvas. Separate so consumers who don't want a graph
        // editor don't pay for it. (macOS / iOS)
        .library(name: "CanvasUI", targets: ["CanvasUI"]),
        // Living showcase of every component. Ships with the package so any
        // consumer can drop it in a window and eyeball the whole set.
        // (macOS / iOS)
        .library(name: "AIElementsGallery", targets: ["AIElementsGallery"]),
    ],
    targets: [
        // `swift run ShadKitDemo` opens the gallery in a window.
        .executableTarget(
            name: "ShadKitDemo",
            dependencies: ["AIElementsGallery", "ShadcnUI"]
        ),
        .target(name: "ShadcnUI"),
        .target(name: "AIElementsUI", dependencies: ["ShadcnUI"]),
        .target(name: "CanvasUI", dependencies: ["ShadcnUI"]),
        .target(name: "AIElementsGallery", dependencies: ["ShadcnUI", "AIElementsUI", "CanvasUI"]),
        .testTarget(
            name: "ShadKitTests",
            dependencies: ["ShadcnUI", "AIElementsUI", "CanvasUI", "AIElementsGallery"]),
    ]
)
