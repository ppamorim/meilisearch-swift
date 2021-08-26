@testable import MeiliSearch
import XCTest

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
private struct Movie: Codable, Equatable {

  let id: Int
  let title: String
  let poster: String
  let overview: String
  let releaseDate: Date

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case poster
    case overview
    case releaseDate = "release_date"
  }

}

class SearchTests: XCTestCase {

  private var client: MeiliSearch!
  private let session = MockURLSession()

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
  }

  func testSearchForBotmanMovie() {

    // Prepare the mock server

    let jsonString = """
      {
        "hits": [
          {
            "id": 29751,
            "title": "Batman Unmasked: The Psychology of the Dark Knight",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 471474,
            "title": "Batman: Gotham by Gaslight",
            "poster": "https://image.tmdb.org/t/p/w1280/7souLi5zqQCnpZVghaXv0Wowi0y.jpg",
            "overview": "ve Victorian Age Gotham City, Batman begins his war on crime",
            "release_date": "2020-04-04T19:59:49.259572Z"
          }
        ],
        "offset": 0,
        "limit": 20,
        "processingTimeMs": 2,
        "nbHits": 2,
        "query": "botman"
      }
      """

    let data = jsonString.data(using: .utf8)!

    let stubSearchResult: SearchResult<Movie> = try! Constants.customJSONDecoder.decode(SearchResult<Movie>.self, from: data)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let uid: String = "Movies"

    let searchParameters = SearchParameters.query("botman")

    let expectation = XCTestExpectation(description: "Searching for botman")

    typealias MeiliResult = Result<SearchResult<Movie>, Swift.Error>

    self.client.search(UID: uid, searchParameters) { (result: MeiliResult) in
      switch result {
      case .success(let searchResult):
        XCTAssertEqual(stubSearchResult, searchResult)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search for botman")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testSearchForBotmanMovieFacets() {

    // Prepare the mock server

    let jsonString = """
      {
        "hits": [
          {
            "id": 29751,
            "title": "Batman Unmasked: The Psychology of the Dark Knight",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 471474,
            "title": "Batman: Gotham by Gaslight",
            "poster": "https://image.tmdb.org/t/p/w1280/7souLi5zqQCnpZVghaXv0Wowi0y.jpg",
            "overview": "ve Victorian Age Gotham City, Batman begins his war on crime",
            "release_date": "2020-04-04T19:59:49.259572Z"
          }
        ],
        "offset": 0,
        "limit": 20,
        "processingTimeMs": 2,
        "nbHits": 2,
        "query": "botman"
      }
      """

    let data = jsonString.data(using: .utf8)!

    let stubSearchResult: SearchResult<Movie> = try! Constants.customJSONDecoder.decode(SearchResult<Movie>.self, from: data)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let uid: String = "Movies"

    let searchParameters = SearchParameters(
      query: "botman",
      filter: "genre = romance OR genre = Science Fiction)"
    )

    let expectation = XCTestExpectation(description: "Searching for botman")

    typealias MeiliResult = Result<SearchResult<Movie>, Swift.Error>

    self.client.search(UID: uid, searchParameters) { (result: MeiliResult) in
      switch result {
      case .success(let searchResult):
        XCTAssertEqual(stubSearchResult, searchResult)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search for botman")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  static var allTests = [
    ("testSearchForBotmanMovie", testSearchForBotmanMovie),
    ("testSearchForBotmanMovieFacets", testSearchForBotmanMovieFacets)
  ]

}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
