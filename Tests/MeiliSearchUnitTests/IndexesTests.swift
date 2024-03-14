@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest

class IndexesTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private let uid: String = "movies_test"
  private let session = MockURLSession()

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index(self.uid)
  }

  func testCreateIndex() async throws {
    let jsonString = """
      {
        "taskUid": 0,
        "indexUid": "books",
        "status": "enqueued",
        "type": "indexCreation",
        "enqueuedAt": "2022-07-21T21:57:14.052648139Z"
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let task = try await self.client.createIndex(uid: self.uid)
    XCTAssertEqual(0, task.taskUid)
  }

  func testGetIndexWithClient() async throws {
    let jsonString = """
      {
        "name":"Movies",
        "uid":"movies_test",
        "createdAt":"2020-04-04T19:59:49.259572Z",
        "updatedAt":"2020-04-04T19:59:49.259579Z",
        "primaryKey":null
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let index = try await self.client.getIndex(uid)
    XCTAssertEqual(self.uid, index.uid)
  }

  func testGetIndex() async throws {
    let jsonString = """
      {
        "name":"Movies",
        "uid":"movies_test",
        "createdAt":"2020-04-04T19:59:49.259572Z",
        "updatedAt":"2020-04-04T19:59:49.259579Z",
        "primaryKey":null
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let index = try await self.index.get()
    XCTAssertEqual(self.uid, index.uid)
  }

  func testGetIndexes() async throws {
    let jsonString = """
      {
        "results": [
          {
            "uid": "movies",
            "createdAt": "2022-07-21T21:18:46.767583668Z",
            "updatedAt": "2022-07-21T21:47:50.583352169Z",
            "primaryKey": "id"
          },
        ],
        "offset": 0,
        "limit": 10,
        "total": 1
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let indexes = try await self.client.getIndexes()
    XCTAssertEqual("movies", indexes.results[0].uid)
  }

  func testUpdateIndexWithClient() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"books","status":"enqueued","type":"indexUpdate","enqueuedAt":"2022-07-21T22:03:40.482534429Z"}
      """

    // Prepare the mock server
    session.pushData(jsonString)
    let primaryKey: String = "movie_review_id"

    // Start the test with the mocked server
    let task = try await self.client.updateIndex(uid: self.uid, primaryKey: primaryKey)
    XCTAssertEqual(0, task.taskUid)
  }

  func testUpdateIndex() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"books","status":"enqueued","type":"indexUpdate","enqueuedAt":"2022-07-21T22:03:40.482534429Z"}
    """

    // Prepare the mock server
    session.pushData(jsonString)
    let primaryKey: String = "movie_review_id"

    // Start the test with the mocked server
    let task = try await self.index.update(primaryKey: primaryKey)
    XCTAssertEqual(0, task.taskUid)
  }

  func testGetIndexesWithParameters() async throws {
    let jsonString = """
      {
        "results": [],
        "offset": 1,
        "limit": 9,
        "total": 0
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    _ = try await self.client.getIndexes(params: IndexesQuery(limit: 9, offset: 1))
    XCTAssertEqual(self.session.nextDataTask.request?.url?.query, "limit=9&offset=1")
  }

  func testGetTasksWithParametersFromIndex() async throws {
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
    _ = try await self.index.getTasks(params: TasksQuery(limit: 20, from: 5, next: 98, types: [.indexCreation]))
    let requestQuery = self.session.nextDataTask.request?.url?.query
    XCTAssertEqual(requestQuery, "from=5&indexUids=\(self.uid)&limit=20&next=98&types=indexCreation")
  }

  func testDeleteIndexWithClient() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"books","status":"enqueued","type":"indexDeletion","enqueuedAt":"2022-07-21T22:05:00.976623757Z"}
    """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let task = try await self.client.deleteIndex(self.uid)
    XCTAssertEqual(0, task.taskUid)
  }

  func testDeleteIndex() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"books","status":"enqueued","type":"indexDeletion","enqueuedAt":"2022-07-21T22:05:00.976623757Z"}
    """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let task = try await self.index.delete()
    XCTAssertEqual(0, task.taskUid)
  }
}
