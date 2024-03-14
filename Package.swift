// swift-tools-version:5.2

import PackageDescription

let MeiliSearch = "MeiliSearch"
let MeiliSearchCore = "MeiliSearchCore"
let MeiliSearchNIO = "MeiliSearchNIO"

var products: [PackageDescription.Product] = [
  .library(name: MeiliSearch, targets: [MeiliSearch]),
  .library(name: MeiliSearchCore, targets: [MeiliSearchCore])
]

var dependencies = [PackageDescription.Package.Dependency]()

var targets: [PackageDescription.Target] = [
  .target(
    name: MeiliSearch,
    dependencies: [
      .target(name: MeiliSearchCore)
    ]
  ),
  .target(
    name: MeiliSearchCore, 
    dependencies: []
  ),
  .testTarget(
    name: "MeiliSearchUnitTests",
    dependencies: ["MeiliSearch"]
  ),
  .testTarget(
    name: "MeiliSearchIntegrationTests",
    dependencies: ["MeiliSearch"]
  )
]

#if os(Linux) || USE_NIO
products.append(.library(name: MeiliSearchNIO, targets: [MeiliSearchNIO]))
dependencies.append(.package(url: "https://github.com/swift-server/async-http-client.git", from: "1.19.0"))
targets.append(
  .target(
    name: MeiliSearchNIO,
    dependencies: [
      .product(name: "AsyncHTTPClient", package: "async-http-client"),
      .target(name: MeiliSearchCore)
    ]
  )
)

targets.append(
  .testTarget(
    name: "MeiliSearchNIOTests",
    dependencies: [
      .target(name: MeiliSearchNIO)
    ]
  )
)
#endif

let package = Package(
  name: "meilisearch-swift",
  products: products,
  dependencies: dependencies,
  targets: targets
)
