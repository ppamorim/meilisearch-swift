@testable import MeiliSearch
import XCTest

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
class SystemTests: XCTestCase {

  private var client: MeiliSearch!

  private let session = MockURLSession()

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
  }

  func testHealthStatusAvailable() {

    // Prepare the mock server

    let jsonString = """
      {
        "status": "available"
      }
      """

    let jsonData = jsonString.data(using: .utf8)!

    let expectedHealthBody: Health = try! Constants.customJSONDecoder.decode(Health.self, from: jsonData)

    session.pushData(jsonString, code: 200)

    // Start the test with the mocked server

    let expectation = XCTestExpectation(description: "Check body of health server on health method")

    self.client.health { result in
      switch result {
      case .success(let body):
        XCTAssertEqual(expectedHealthBody, body)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed on available status check on health method")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testIsHealthyTrue() {

    // Prepare the mock server

    let jsonString = """
      {
        "status": "available"
      }
      """

    session.pushData(jsonString, code: 200)

    // Start the test with the mocked server

    let expectation = XCTestExpectation(description: "Check if is healthy is true")

    self.client.isHealthy { result in
      if result == true {
        XCTAssertEqual(result, true)
        expectation.fulfill()
      } else {
        XCTFail("Failed on isHealthy should be true")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testIsHealthyFalse() {

    // Prepare the mock server

    session.pushData("", code: 400)

    // Start the test with the mocked server

    let expectation = XCTestExpectation(description: "Check if is healthy is false")

    self.client.isHealthy { result in
      if result == false {
        XCTAssertEqual(result, false)
        expectation.fulfill()
      } else {
        XCTFail("Failed on isHealthy should be false")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testVersion() {

    // Prepare the mock server

    let jsonString = """
      {
        "commitSha": "b46889b5f0f2f8b91438a08a358ba8f05fc09fc1",
        "commitDate": "2019-11-15T09:51:54.278247+00:00",
        "pkgVersion": "0.1.1"
      }
      """

    let jsonData = jsonString.data(using: .utf8)!

    let stubVersion: Version = try! Constants.customJSONDecoder.decode(Version.self, from: jsonData)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let expectation = XCTestExpectation(description: "Load server version")

    self.client.version { result in

      switch result {
      case .success(let version):
        XCTAssertEqual(stubVersion, version)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to load server version")
      }

    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  static var allTests = [
    ("testHealthStatusAvailable", testHealthStatusAvailable),
    ("testIsHealthyTrue", testIsHealthyTrue),
    ("testIsHealthyFalse", testIsHealthyFalse),
    ("testVersion", testVersion)
  ]
}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
