@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest

class TasksTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private let uid: String = "movies_test"
  private let session = MockURLSession()

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index(self.uid)
  }

  func testGetTasksWithParametersFromClient() async throws {
    let jsonString = """
      {
        "results": [],
        "limit": 20,
        "from": 5,
        "next": 98,
        "total": 6
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let params = TasksQuery(limit: 20, from: 5, next: 98, types: [.indexCreation])
    _ = try await self.client.getTasks(params: params)

    let requestQuery = self.session.nextDataTask.request?.url?.query
    XCTAssertEqual(requestQuery, "from=5&limit=20&next=98&types=indexCreation")
  }
}
