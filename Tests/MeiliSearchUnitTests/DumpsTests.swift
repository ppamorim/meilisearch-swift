@testable import MeiliSearch
import XCTest

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
class DumpsTests: XCTestCase {

  private var client: MeiliSearch!
  private let session = MockURLSession()

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
  }

  func testCreateDump() {

    // Prepare the mock server

    let json = """
      {
        "uid": "20200929-114144097",
        "status": "in_progress",
        "startedAt": "2021-06-01T14:43:39.392327Z"
      }
      """

    let data = json.data(using: .utf8)!

    let stubDump: Dump = try! Constants.customJSONDecoder.decode(Dump.self, from: data)

    session.pushData(json)

    // Start the test with the mocked server

    let expectation = XCTestExpectation(description: "Create dump")

    self.client.createDump { result in
      switch result {
      case .success(let dump):
        XCTAssertEqual(stubDump, dump)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to create dump")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testGetDumpStatus() {

    // Prepare the mock server

    let json = """
      {
        "uid": "20200929-114144097",
        "status": "in_progress",
        "startedAt": "2021-06-01T14:43:39.392327Z"
      }
      """

    let data = json.data(using: .utf8)!

    let stubDump: Dump = try! Constants.customJSONDecoder.decode(Dump.self, from: data)

    session.pushData(json)

    // Start the test with the mocked server

    let UID: String = "20200929-114144097"

    let expectation = XCTestExpectation(description: "Get the dump status")

    self.client.getDumpStatus(UID: UID) { result in
      switch result {
      case .success(let dump):
        XCTAssertEqual(stubDump, dump)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get the dump status")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  static var allTests = [
    ("testGetDumpStatus", testGetDumpStatus),
    ("testGetSetting", testGetDumpStatus)
  ]

}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
