@testable import MeiliSearch
@testable import MeiliSearchCore

import XCTest

class DocumentsQueryTests: XCTestCase {
  func testRenderedQuery() {
    let data: [[String: DocumentsQuery]] = [
      ["?limit=2": DocumentsQuery(limit: 2)],
      ["?fields=name,title&limit=2&offset=99": DocumentsQuery(limit: 2, offset: 99, fields: ["name", "title"])],
      ["?limit=2": DocumentsQuery(limit: 2, offset: nil)],
      ["?offset=2": DocumentsQuery(offset: 2)],
      ["?limit=10&offset=0": DocumentsQuery(limit: 10, offset: 0)],
      ["?fields=&offset=0": DocumentsQuery(offset: 0, fields: [])],
      ["": DocumentsQuery()]
    ]

    data.forEach { dict in
      XCTAssertEqual(dict.first?.value.toQuery(), dict.first?.key)
    }
  }
}
