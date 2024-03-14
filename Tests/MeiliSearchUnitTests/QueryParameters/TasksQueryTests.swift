@testable import MeiliSearch
@testable import MeiliSearchCore

import XCTest

class TasksQueryTests: XCTestCase {
  var sampleDate = Date(timeIntervalSince1970: TimeInterval(1553249221))

  func testRenderedQuery() {
    let data: [[String: TasksQuery]] = [
      ["?limit=2": TasksQuery(limit: 2)],
      ["?from=99&limit=2&types=indexSwap,dumpCreation": TasksQuery(limit: 2, from: 99, types: [.indexSwap, .dumpCreation])],
      ["?limit=2": TasksQuery(limit: 2, next: nil)],
      ["?from=2": TasksQuery(from: 2)],
      ["?indexUids=my-index,123": TasksQuery(indexUids: ["my-index", "123"])],
      ["?limit=10&next=0": TasksQuery(limit: 10, next: 0)],
      ["?beforeEnqueuedAt=2019-03-22T10:07:01.000Z&next=10": TasksQuery(next: 10, beforeEnqueuedAt: sampleDate)],
      ["": TasksQuery()]
    ]

    data.forEach { dict in
      XCTAssertEqual(dict.first?.value.toQuery(), dict.first?.key)
    }
  }
}
