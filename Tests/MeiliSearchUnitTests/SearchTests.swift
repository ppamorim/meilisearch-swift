@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest

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
  private var index: Indexes!
  private let session = MockURLSession()

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index("movies_test")
  }

  func testSearchForBotmanMovie() async throws {
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
        "estimatedTotalHits": 2,
        "query": "botman"
      }
      """

    // Prepare the mock server
    let stubSearchResult: Searchable<Movie> = try decodeJSON(from: jsonString)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let searchParameters = SearchParameters.query("botman")
    let searchResult: Searchable<Movie> = try await self.index.search(searchParameters)
    XCTAssertEqual(stubSearchResult, searchResult)
  }

  func testSearchForBotmanMovieFacets() async throws {
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
        "estimatedTotalHits": 2,
        "query": "botman"
      }
      """

    // Prepare the mock server
    let stubSearchResult: Searchable<Movie> = try decodeJSON(from: jsonString)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let searchParameters = SearchParameters(
      query: "botman",
      filter: "genre = romance OR genre = Science Fiction",
      sort: ["id:asc"]
    )

    let searchResult: Searchable<Movie> = try await self.index.search(searchParameters)
    XCTAssertEqual(stubSearchResult, searchResult)
  }

  func testShouldFilterValuesWithSpaces() async throws {
    let jsonString = """
      {
        "hits": [
          {
            "id": 123,
            "title": "Pride and Prejudice",
            "comment": "A great book",
            "genre": "romance",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 456,
            "title": "Le Petit Prince",
            "comment": "A french book about a prince that walks on little cute planets",
            "genre": "adventure",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 2,
            "title": "Le Rouge et le Noir",
            "comment": "Another french book",
            "genre": "romance",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 1,
            "title": "Alice In Wonderland",
            "comment": "A weird book",
            "genre": "adventure",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 1344,
            "title": "The Hobbit",
            "comment": "An awesome book",
            "genre": "sci fi",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 4,
            "title": "Harry Potter and the Half-Blood Prince",
            "comment": "The best book",
            "genre": "fantasy",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 42,
            "title": "The Hitchhiker's Guide to the Galaxy",
            "genre": "fantasy",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          }
        ],
        "offset": 0,
        "limit": 20,
        "processingTimeMs": 2,
        "estimatedTotalHits": 1,
        "query": "h",
        "genre": "sci fi"
      }
      """

    // Prepare the mock server
    guard let data = jsonString.data(using: .utf8), let stubSearchResult: Searchable<Movie> = try? Constants.customJSONDecoder.decode(Searchable<Movie>.self, from: data) else {
      XCTFail("Failed to encode JSON data")
      return
    }

    session.pushData(jsonString)

    // Start the test with the mocked server
    let searchParameters = SearchParameters(
      query: "h",
      filter: "genre = 'sci fi'",
      sort: ["id:asc"]
    )

    let searchResult: Searchable<Movie> = try await index.search(searchParameters)
    XCTAssertEqual(stubSearchResult, searchResult)
  }

  func testSearchWithFinitePagination() async throws {
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
        "query": "botman",
        "processingTimeMs": 2,
        "hitsPerPage": 20,
        "page": 1,
        "totalPages": 1,
        "totalHits": 2
      }
      """

    // Prepare the mock server
    let stubSearchResult: Searchable<Movie> = try decodeJSON(from: jsonString)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let searchParameters = SearchParameters(query: "botman", hitsPerPage: 10)
    let searchResult: Searchable<Movie> = try await self.index.search(searchParameters)
    let result = searchResult as! FiniteSearchResult<Movie>

    XCTAssertEqual(stubSearchResult, searchResult)
    XCTAssertEqual(result.totalPages, 1)
    XCTAssertEqual(result.totalHits, 2)
    XCTAssertEqual(result.page, 1)
    XCTAssertEqual(result.query, "botman")
    XCTAssertEqual(result.processingTimeMs, 2)
  }
}
