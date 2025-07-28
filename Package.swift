// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "AzureAIVisionFaceUI",
    products: [
        .library(
            name: "AzureAIVisionFaceUI",
            targets: ["AzureAIVisionFaceUI"]),
    ],
    targets: [
        .binaryTarget(
            name: "AzureAIVisionFaceUI",
            path: "AzureAIVisionFaceUI.xcframework"
        )
    ]
)

