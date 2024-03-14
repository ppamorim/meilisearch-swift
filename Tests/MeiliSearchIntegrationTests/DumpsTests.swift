@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class DumpsTests: XCTestCase {
  private var client: MeiliSearch!
  private var session: URLSessionProtocol!

  // MARK: Setup

  override func setUpWithError() throws {
    try super.setUpWithError()
    if client == nil {
      session = URLSession(configuration: .ephemeral)
      client = try MeiliSearch(host: currentHost(), apiKey: "masterKey", session: session)
    }
  }

  func testCreateAndGetDump() {
    let expectation = XCTestExpectation(description: "Request dump status")

    self.client.createDump { result in
      switch result {
      case .success(let dumpTask):
        XCTAssertEqual(dumpTask.status, Task.Status.enqueued)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to request dump creation \(error)")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }
}
