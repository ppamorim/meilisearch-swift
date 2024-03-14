@testable import MeiliSearch
@testable import MeiliSearchCore

import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
import XCTest

class PackageVersionTests: XCTestCase {
  func testAppendsContentsToPrefix() {
    XCTAssert(PackageVersion.qualifiedVersion().contains("Meilisearch Swift"))
  }

  func testGetsFullyQualifiedVersion() {
    XCTAssertEqual(PackageVersion.qualifiedVersion("0.3.2"), "Meilisearch Swift (v0.3.2)")
  }

  func testChecksForSemVerVersion() {
    let version = PackageVersion.qualifiedVersion()
    let regex = "[0-9]+.[0-9]+.[0-9]+"

    let hasSemVer = (version.range(of: regex, options: .regularExpression) ?? nil) != nil

    XCTAssert(hasSemVer, "The PackageVersion.current does not have a valid semver version.")
  }
}
