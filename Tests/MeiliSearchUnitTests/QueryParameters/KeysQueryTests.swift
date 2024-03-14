@testable import MeiliSearch
@testable import MeiliSearchCore

import XCTest

class KeysQueryTests: XCTestCase {
  func testRenderedQuery() {
    let data: [[String: KeysQuery]] = [
      ["?limit=2": KeysQuery(limit: 2)],
      ["?limit=2&offset=99": KeysQuery(limit: 2, offset: 99)],
      ["?limit=2": KeysQuery(limit: 2, offset: nil)],
      ["?offset=2": KeysQuery(offset: 2)],
      ["?limit=10&offset=0": KeysQuery(limit: 10, offset: 0)],
      ["": KeysQuery()]
    ]

    data.forEach { dict in
      XCTAssertEqual(dict.first?.value.toQuery(), dict.first?.key)
    }
  }
}
