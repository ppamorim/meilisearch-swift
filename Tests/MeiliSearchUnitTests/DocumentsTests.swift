@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

private struct Movie: Codable, Equatable {
  let id: Int
  let title: String
  let overview: String?
  let releaseDate: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case overview
    case releaseDate = "release_date"
  }
}

class DocumentsTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private var uid: String = "movies_test"
  private let session = MockURLSession()

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = self.client.index(self.uid)
  }

  func testAddDocuments() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"books_test","status":"enqueued","type":"documentAdditionOrUpdate","enqueuedAt":"2022-07-21T21:47:50.565717794Z"}
    """

    // Prepare the mock server
    let stubTask: TaskInfo = try decodeJSON(from: jsonString)
    session.pushData(jsonString, code: 202)

    // Start the test with the mocked server
    let movie = Movie(
      id: 287947,
      title: "Shazam",
      overview: "A boy is given the ability to become an adult superhero in times of need with a single magic word.",
      releaseDate: Date(timeIntervalSince1970: TimeInterval(1553299200))
    )

    let update = try await self.index.addDocuments(documents: [movie], primaryKey: "id")
    XCTAssertEqual(stubTask.taskUid, update.taskUid)
  }

  func testAddDataDocuments() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"books_test","status":"enqueued","type":"documentAdditionOrUpdate","enqueuedAt":"2022-07-21T21:47:50.565717794Z"}
      """

    // Prepare the mock server
    let stubTask: TaskInfo = try decodeJSON(from: jsonString)
    session.pushData(jsonString, code: 202)

    let documentJsonString = """
      [{
        "id": 287947,
        "title": "Shazam",
        "poster": "https://image.tmdb.org/t/p/w1280/xnopI5Xtky18MPhK40cZAGAOVeV.jpg",
        "overview": "A boy is given the ability to become an adult superhero in times of need with a single magic word.",
        "release_date": "2019-03-23"
      }]
      """

    let primaryKey: String = ""
    let documents: Data = Data(documentJsonString.utf8)

    // Start the test with the mocked server
    let update = try await self.index.addDocuments(documents: documents, primaryKey: primaryKey)
    XCTAssertEqual(stubTask, update)
  }

  func testUpdateDataDocuments() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"books_test","status":"enqueued","type":"documentAdditionOrUpdate","enqueuedAt":"2022-07-21T21:47:50.565717794Z"}
      """

    // Prepare the mock server
    let stubTask: TaskInfo = try decodeJSON(from: jsonString)
    session.pushData(jsonString, code: 202)
    let documentJsonString = """
      [{
        "id": 287947,
        "title": "Shazam ⚡️"
      }]
      """

    let primaryKey: String = "movieskud"
    let JsonDocuments: Data = Data(documentJsonString.utf8)

    // Start the test with the mocked server
    let update = try await self.index.updateDocuments(documents: JsonDocuments, primaryKey: primaryKey)
    XCTAssertEqual(stubTask, update)
  }

  func testUpdateDocuments() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"books_test","status":"enqueued","type":"documentAdditionOrUpdate","enqueuedAt":"2022-07-21T21:47:50.565717794Z"}
      """

    // Prepare the mock server
    let stubTask: TaskInfo = try decodeJSON(from: jsonString)
    session.pushData(jsonString, code: 202)

    let movie = Movie(
      id: 287947,
      title: "Shazam",
      overview: "A boy is given the ability to become an adult superhero in times of need with a single magic word.",
      releaseDate: Date(timeIntervalSince1970: TimeInterval(1553299200))
    )

    // Start the test with the mocked server
    let update = try await self.index.updateDocuments(documents: [movie], primaryKey: "id")
    XCTAssertEqual(stubTask, update)
  }

  func testGetDocument() async throws {
    let jsonString = """
      {
        "id": 25684,
        "title": "American Ninja 5",
        "poster": "https://image.tmdb.org/t/p/w1280/iuAQVI4mvjI83wnirpD8GVNRVuY.jpg",
        "overview": "When a scientists daughter is kidnapped, American Ninja, attempts to find her, but this time he teams up with a youngster he has trained in the ways of the ninja.",
        "release_date": "2020-04-04T19:59:49.259572Z"
      }
      """

    // Prepare the mock server
    session.pushData(jsonString, code: 200)
    let stubMovie: Movie = try decodeJSON(from: jsonString)
    let identifier: String = "25684"

    // Start the test with the mocked server
    let movie: Movie = try await self.index.getDocument(identifier)
    XCTAssertEqual(stubMovie, movie)
  }

  func testGetDocumentWithSparseFieldsets() async throws {
    let jsonString = """
      {
        "id": 25684,
        "title": "American Ninja 5"
      }
      """

    // Prepare the mock server
    session.pushData(jsonString, code: 200)

    let stubMovie: Movie = try decodeJSON(from: jsonString)
    let identifier: String = "25684"

    // Start the test with the mocked server
    let movie: Movie = try await self.index.getDocument(identifier, fields: ["title", "id"])
    XCTAssertEqual(self.session.nextDataTask.request?.url?.query, "fields=title,id")

    XCTAssertEqual(stubMovie, movie)
  }

  func testGetDocumentsWithParameters() async throws {
    let jsonString = """
      {
        "results": [],
        "offset": 10,
        "limit": 2,
        "total": 0
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let _: DocumentsResults<Movie> = try await self.index.getDocuments(params: DocumentsQuery(limit: 2, offset: 10))
    XCTAssertEqual(self.session.nextDataTask.request?.url?.query, "limit=2&offset=10")
  }

  func testGetDocuments() async throws {
    let jsonString = """
      {
        "results": [
          {
            "id": 25684,
            "release_date": "2020-04-04T19:59:49.259572Z",
            "poster": "https://image.tmdb.org/t/p/w1280/iuAQVI4mvjI83wnirpD8GVNRVuY.jpg",
            "title": "American Ninja 5",
            "overview": "When a scientists daughter is kidnapped, American Ninja, attempts to find her, but this time he teams up with a youngster he has trained in the ways of the ninja."
          },
          {
            "id": 468219,
            "title": "Dead in a Week (Or Your Money Back)",
            "release_date": "2020-04-04T19:59:49.259572Z",
            "poster": "https://image.tmdb.org/t/p/w1280/f4ANVEuEaGy2oP5M0Y2P1dwxUNn.jpg",
            "overview": "William has failed to kill himself so many times that he outsources his suicide to aging assassin Leslie. But with the contract signed and death assured within a week (or his money back), William suddenly discovers reasons to live... However Leslie is under pressure from his boss to make sure the contract is completed."
          }
        ],
        "limit": 2,
        "offset": 0,
        "total": 10
      }
      """

    // Prepare the mock server
    session.pushData(jsonString, code: 200)
    let stubMovies: DocumentsResults<Movie> = try decodeJSON(from: jsonString)

    // Start the test with the mocked server
    let movies: DocumentsResults<Movie> = try await self.index.getDocuments()
    XCTAssertEqual(stubMovies, movies)
  }

  func testDeleteDocument() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"books_test","status":"enqueued","type":"documentAdditionOrUpdate","enqueuedAt":"2022-07-21T21:47:50.565717794Z"}
    """

    // Prepare the mock server
    let stubTask: TaskInfo = try decodeJSON(from: jsonString)
    session.pushData(jsonString, code: 202)
    let identifier: String = "25684"

    // Start the test with the mocked server
    let update = try await self.index.deleteDocument(identifier)
    XCTAssertEqual(stubTask, update)
  }

  func testDeleteAllDocuments() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"books_test","status":"enqueued","type":"documentAdditionOrUpdate","enqueuedAt":"2022-07-21T21:47:50.565717794Z"}
      """

    // Prepare the mock server
    let stubTask: TaskInfo = try decodeJSON(from: jsonString)
    session.pushData(jsonString, code: 202)

    // Start the test with the mocked server
    let update = try await self.index.deleteAllDocuments()
    XCTAssertEqual(stubTask, update)
  }

  func testDeleteBatchDocuments() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"books_test","status":"enqueued","type":"documentAdditionOrUpdate","enqueuedAt":"2022-07-21T21:47:50.565717794Z"}
    """

    // Prepare the mock server
    let stubTask: TaskInfo = try decodeJSON(from: jsonString)
    session.pushData(jsonString, code: 202)
    let documentsIdentifiers: [String] = ["23488", "153738", "437035", "363869"]

    // Start the test with the mocked server
    let update = try await self.index.deleteBatchDocuments(documentsIdentifiers)
    XCTAssertEqual(stubTask, update)
  }

  @available(*, deprecated, message: "Testing deprecated methods - marked deprecated to avoid additional warnings below.")
  func testDeprecatedDeleteBatchDocuments() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"books_test","status":"enqueued","type":"documentAdditionOrUpdate","enqueuedAt":"2022-07-21T21:47:50.565717794Z"}
    """

    // Prepare the mock server
    let stubTask: TaskInfo = try decodeJSON(from: jsonString)
    session.pushData(jsonString, code: 202)
    let documentsIdentifiers: [Int] = [23488, 153738, 437035, 363869]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Delete all Movies documents")
    self.index.deleteBatchDocuments(documentsIdentifiers) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to delete all Movies documents")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }
}
