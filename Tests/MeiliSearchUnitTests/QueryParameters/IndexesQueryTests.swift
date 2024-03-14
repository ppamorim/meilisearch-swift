@testable import MeiliSearch
@testable import MeiliSearchCore

import XCTest

class IndexesQueryTests: XCTestCase {
  func testRenderedQuery() {
    let data: [[String: IndexesQuery]] = [
      ["?limit=2": IndexesQuery(limit: 2)],
      ["?limit=2&offset=99": IndexesQuery(limit: 2, offset: 99)],
      ["?limit=2": IndexesQuery(limit: 2, offset: nil)],
      ["?offset=2": IndexesQuery(offset: 2)],
      ["?limit=10&offset=0": IndexesQuery(limit: 10, offset: 0)],
      ["": IndexesQuery()]
    ]

    data.forEach { dict in
      XCTAssertEqual(dict.first?.value.toQuery(), dict.first?.key)
    }
  }
}
