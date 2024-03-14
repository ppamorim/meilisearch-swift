@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest

class SystemTests: XCTestCase {
  private var client: MeiliSearch!

  private let session = MockURLSession()

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
  }

  func testHealthStatusAvailable() async throws {
    // Prepare the mock server
    let jsonString = """
    {
      "status": "available"
    }
    """

    let expectedHealthBody: Health = try decodeJSON(from: jsonString)
    session.pushData(jsonString, code: 200)

    // Start the test with the mocked server
    let body = try await self.client.health()
    XCTAssertEqual(expectedHealthBody, body)
  }

  func testIsHealthyTrue() async throws {
    // Prepare the mock server
    let jsonString = """
    {
      "status": "available"
    }
    """

    session.pushData(jsonString, code: 200)

    // Start the test with the mocked server
    let result = await self.client.isHealthy()
    XCTAssertTrue(result)
  }

  func testIsHealthyFalse() async throws {
    // Prepare the mock server
    session.pushData("", code: 400)

    // Start the test with the mocked server
    let result = await self.client.isHealthy()
    XCTAssertFalse(result)
  }

  func testVersion() async throws {
    // Prepare the mock server
    let jsonString = """
    {
      "commitSha": "b46889b5f0f2f8b91438a08a358ba8f05fc09fc1",
      "commitDate": "2019-11-15T09:51:54.278247+00:00",
      "pkgVersion": "0.1.1"
    }
    """

    let stubVersion: Version = try decodeJSON(from: jsonString)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let version = try await client.version()
    XCTAssertEqual(stubVersion, version)
  }
}
