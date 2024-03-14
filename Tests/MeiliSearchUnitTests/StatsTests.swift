@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest

class StatsTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private var uid: String = "movies_test"
  private let session = MockURLSession()

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index(self.uid)
  }

  func testStats() async throws {
    let jsonString = """
      {
        "numberOfDocuments": 19654,
        "isIndexing": false,
        "fieldDistribution": {
          "poster": 19654,
          "release_date": 19654,
          "title": 19654,
          "id": 19654,
          "overview": 19654
        }
      }
      """

    // Prepare the mock server
    let stubStats: Stat = try decodeJSON(from: jsonString)

    session.pushData(jsonString)

    // Start the test with the mocked server
    let stats = try await self.index.stats()
    XCTAssertEqual(stubStats, stats)
  }

  func testAllStats() async throws {
    let jsonString = """
      {
        "databaseSize": 447819776,
        "lastUpdate": "2019-11-15T11:15:22.092896Z",
        "indexes": {
          "movies": {
            "numberOfDocuments": 19654,
            "isIndexing": false,
            "fieldDistribution": {
              "poster": 19654,
              "overview": 19654,
              "title": 19654,
              "id": 19654,
              "release_date": 19654
            }
          },
          "rangemovies": {
            "numberOfDocuments": 19654,
            "isIndexing": false,
            "fieldDistribution": {
              "overview": 19654,
              "id": 19654,
              "title": 19654
            }
          }
        }
      }
      """
    // Prepare the mock server
    let stubAllStats: AllStats = try decodeJSON(from: jsonString)

    session.pushData(jsonString)

    // Start the test with the mocked server
    let allStats = try await self.client.allStats()
    XCTAssertEqual(stubAllStats, allStats)
  }
}
