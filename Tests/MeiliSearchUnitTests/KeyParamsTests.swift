@testable import MeiliSearch
@testable import MeiliSearchCore

import XCTest

class KeyParamsTests: XCTestCase {
  func testCompleteInitializer() {
    let keyParams = KeyParams(
      description: "The default search key",
      name: "Default Search Key",
      uid: "74c9c733-3368-4738-bbe5-1d18a5fecb37",
      actions: ["action1"],
      indexes: ["index1"],
      expiresAt: "2021-08-11T10:00:00Z"
    )

    XCTAssertEqual(keyParams.actions, ["action1"])
    XCTAssertEqual(keyParams.indexes, ["index1"])
    XCTAssertEqual(keyParams.expiresAt, "2021-08-11T10:00:00Z")
    XCTAssertEqual(keyParams.description, "The default search key")
    XCTAssertEqual(keyParams.name, "Default Search Key")
    XCTAssertEqual(keyParams.uid, "74c9c733-3368-4738-bbe5-1d18a5fecb37")
  }

  func testCompactInitializer() {
    let keyParams = KeyParams(actions: ["action1"], indexes: ["index1"], expiresAt: nil)

    XCTAssertEqual(keyParams.actions, ["action1"])
    XCTAssertEqual(keyParams.indexes, ["index1"])
    XCTAssertNil(keyParams.expiresAt)
    XCTAssertNil(keyParams.description)
    XCTAssertNil(keyParams.name)
    XCTAssertNil(keyParams.uid)
  }
}
