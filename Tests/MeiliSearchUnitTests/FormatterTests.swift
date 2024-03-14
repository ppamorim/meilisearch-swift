@testable import MeiliSearch
@testable import MeiliSearchCore

import XCTest

class FormatterTests: XCTestCase {
  var optionalDate: Date? = Date(timeIntervalSince1970: TimeInterval(1553249221))
  var sampleDate: Date = Date(timeIntervalSince1970: TimeInterval(1553249221))

  func testformatOptionalDateWithOptionalDate() {
    let response = Formatter.formatOptionalDate(date: optionalDate)

    XCTAssertEqual(response, "2019-03-22T10:07:01.000Z")
  }

  func testformatOptionalDateWithNil() {
    let response = Formatter.formatOptionalDate(date: nil)

    XCTAssertEqual(response, nil)
  }

  func testformatOptionalDateWithValidDate() {
    let response = Formatter.formatOptionalDate(date: sampleDate)

    XCTAssertEqual(response, "2019-03-22T10:07:01.000Z")
  }
}
