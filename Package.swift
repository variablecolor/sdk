// swift-tools-version:5.3
import PackageDescription


let package = Package(
    name: "VariableColor",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "VariableColor",
            targets: ["VariableColor"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "VariableColor",
            url: "https://d1uxfrxqms1qk3.cloudfront.net/uploads/140D0DB8-B309-4FF7-860A-F348C88C573E/output/VariableColor.xcframework.zip",
            checksum: "f3982791fd3e3a814a6c192c5ba26661d8e3b4400c7107de880a0cdad0b37ab1"
        ),
    ]
)