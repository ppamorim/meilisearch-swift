@testable import MeiliSearch
import XCTest
import Foundation

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
private struct Book: Codable, Equatable {

  let id: Int
  let title: String
  let comment: String?
  let genres: [String]?
  let formatted: FormattedBook?
  let matchesInfo: MatchesInfoBook?

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case comment
    case genres
    case formatted = "_formatted"
    case matchesInfo = "_matchesInfo"
  }

  init(id: Int, title: String, comment: String? = nil, genres: [String] = [], formatted: FormattedBook? = nil, matchesInfo: MatchesInfoBook? = nil) {
    self.id = id
    self.title = title
    self.comment = comment
    self.genres = genres
    self.formatted = formatted
    self.matchesInfo = matchesInfo
  }

}

private struct FormattedBook: Codable, Equatable {

  let id: Int
  let title: String
  let comment: String?

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case comment
  }

  init(id: Int, title: String, comment: String? = nil) {
    self.id = id
    self.title = title
    self.comment = comment
  }

}

private struct MatchesInfoBook: Codable, Equatable {
  let comment: [Info]?
  let title: [Info]?
  enum CodingKeys: String, CodingKey {
    case comment
    case title
  }
}

private struct Info: Codable, Equatable {
  let start: Int
  let length: Int
  enum CodingKeys: String, CodingKey {
    case start
    case length
  }
}

private let books: [Book] = [
  Book(id: 123, title: "Pride and Prejudice", comment: "A great book", genres: ["Classic Regency nove"]),
  Book(id: 456, title: "Le Petit Prince", comment: "A french book", genres: ["Novel"]),
  Book(id: 2, title: "Le Rouge et le Noir", comment: "Another french book", genres: ["Bildungsroman"]),
  Book(id: 1, title: "Alice In Wonderland", comment: "A weird book", genres: ["Fantasy"]),
  Book(id: 1344, title: "The Hobbit", comment: "An awesome book", genres: ["High fantasy‎"]),
  Book(id: 4, title: "Harry Potter and the Half-Blood Prince", comment: "The best book", genres: ["Fantasy"]),
  Book(id: 42, title: "The Hitchhiker's Guide to the Galaxy", genres: ["Novel"]),
  Book(id: 1844, title: "A Moreninha", comment: "A Book from Joaquim Manuel de Macedo", genres: ["Novel"])
]

class SearchTests: XCTestCase {

  private var client: MeiliSearch!
  private let uid: String = "books_test"

  // MARK: Setup

  override func setUp() {
    super.setUp()

    if client == nil {
      client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey")
    }

    let documents: Data = try! JSONEncoder().encode(books)

    let expectation = XCTestExpectation(description: "Add documents to index")

    self.client.deleteIndex(UID: uid) { result in

      self.client.getOrCreateIndex(UID: self.uid) { result in

        switch result {
        case .success:

          self.client.addDocuments(
            UID: self.uid,
            documents: documents,
            primaryKey: nil
          ) { result in

            switch result {
            case .success(let update):
              waitForPendingUpdate(self.client, self.uid, update) {
                expectation.fulfill()
              }
            case .failure(let error):
              print(error)
              XCTFail()
            }
          }
        case .failure(let error):
          print(error)
          XCTFail()
        }
      }
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  // MARK: Basic search

  func testBasicSearch() {

    let expectation = XCTestExpectation(description: "Search for Books with query")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let query = "Moreninha"

    self.client.search(UID: self.uid, SearchParameters(query: query)) { (result: MeiliResult) in
      switch result {
      case .success(let response):
        XCTAssertTrue(response.query == query)
        XCTAssertTrue(response.limit == 20)
        XCTAssertTrue(response.hits.count == 1)
        XCTAssertEqual("A Moreninha", response.hits[0].title)
        XCTAssertNil(response.hits[0].formatted)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testBasicSearch")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  func testBasicSearchWithNoQuery() {

    let expectation = XCTestExpectation(description: "Search for Books without query")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>

    self.client.search(UID: self.uid, SearchParameters(query: nil)) { (result: MeiliResult) in
      switch result {
      case .success(let response):
        XCTAssertEqual("", response.query)
        XCTAssertEqual(20, response.limit)
        XCTAssertEqual(books.count, response.hits.count)
        XCTAssertEqual("Alice In Wonderland", response.hits[0].title)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testBasicSearchWithNoQuery")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  // MARK: Phrase search

  func testPhraseSearch() {

    let expectation = XCTestExpectation(description: "Search for Books using phrase search")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    // let limit = 5
    let query = "A \"great book\""

    self.client.search(UID: self.uid, SearchParameters(query: query)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == 20)
        XCTAssertTrue(documents.hits.count == 1)
        XCTAssertEqual("Pride and Prejudice", documents.hits[0].title)
        XCTAssertNil(documents.hits[0].formatted)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testPhraseSearch")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  // MARK: Limit

  func testSearchLimit() {

    let expectation = XCTestExpectation(description: "Search for Books using limit")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = "Moreninha"

    self.client.search(UID: self.uid, SearchParameters(query: query, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 1)
        XCTAssertEqual("A Moreninha", documents.hits[0].title)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testSearchLimit")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  func testSearchZeroLimit() {

    let expectation = XCTestExpectation(description: "Search for Books using zero limit")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 0
    let query = "A Moreninha"

    self.client.search(UID: self.uid, SearchParameters(query: query, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.isEmpty)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testSearchZeroLimit")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  func testSearchLimitBiggerThanNumberOfBooks() {

    let expectation = XCTestExpectation(description: "Search for Books using limit bigger than the number of books stored")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = "A"

    self.client.search(UID: self.uid, SearchParameters(query: query, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == limit)
        XCTAssertNil(documents.hits[0].formatted)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testSearchLimitBiggerThanNumberOfBooks")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  func testSearchLimitEmptySearch() {

    let expectation = XCTestExpectation(description: "Search for Books using limit but nothing in the query")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = ""

    self.client.search(UID: self.uid, SearchParameters(query: query, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 5)
        XCTAssertNil(documents.hits[0].formatted)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testSearchLimitEmptySearch")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  // MARK: Offset

  func testSearchOffset() {

    let expectation = XCTestExpectation(description: "Search for Books using offset")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 2
    let offset = 2
    let query = "A"

    self.client.search(UID: self.uid, SearchParameters(query: query, offset: offset, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.offset == offset)
        XCTAssertTrue(documents.hits.count == 2)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testSearchOffset")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  func testSearchOffsetZero() {

    let expectation = XCTestExpectation(description: "Search for Books using zero offset")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 2
    let offset = 0
    let query = "A"

    self.client.search(UID: self.uid, SearchParameters(query: query, offset: offset, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.offset == offset)
        XCTAssertTrue(documents.hits.count == 2)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testSearchOffsetZero")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  func testSearchOffsetLastPage() {

    let expectation = XCTestExpectation(description: "Search for Books using a offset at the last page")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 2
    let offset = 6
    let query = "A"

    self.client.search(UID: self.uid, SearchParameters(query: query, offset: offset, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.offset == offset)
        XCTAssertTrue(documents.hits.count == 1)
        XCTAssertNil(documents.hits[0].formatted)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testSearchOffsetLastPage")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  // MARK: Attributes to crop

  func testSearchAttributesToCrop() {

    let expectation = XCTestExpectation(description: "Search for Books using attributes to crop")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 2
    let query = "de Macedo"
    let attributesToCrop = ["comment"]
    let cropLength = 5
    let searchParameters = SearchParameters(query: query, limit: limit, attributesToCrop: attributesToCrop, cropLength: cropLength)

    self.client.search(UID: self.uid, searchParameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 1)
        let book: Book = documents.hits[0]
        XCTAssertEqual("Manuel de Macedo", book.formatted!.comment!) // to fix
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testSearchAttributesToCrop")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  // MARK: Crop length

  func testSearchCropLength() {

    let expectation = XCTestExpectation(description: "Search for Books using default crop length")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 2
    let query = "book"
    let attributesToCrop = ["comment"]
    let cropLength = 5
    let searchParameters = SearchParameters(query: query, limit: limit, attributesToCrop: attributesToCrop, cropLength: cropLength)

    self.client.search(UID: self.uid, searchParameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 2)

        let moreninhaBook: Book = documents.hits.first(where: { book in book.id == 1844 })!
        XCTAssertEqual("A Book from", moreninhaBook.formatted!.comment!)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testSearchCropLength")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  // MARK: Matches tests

  func testSearchMatches() {

    let expectation = XCTestExpectation(description: "Search for Books using matches")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = "Moreninha"
    let parameters = SearchParameters(query: query, limit: limit, matches: true)

    self.client.search(UID: self.uid, parameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 1)
        let book = documents.hits[0]
        XCTAssertEqual("A Moreninha", book.title)

        let matchesInfo = book.matchesInfo!
        if let titleMatches = matchesInfo.title {
          let firstMatch = titleMatches[0]
          XCTAssertEqual(2, firstMatch.start)
          XCTAssertEqual(9, firstMatch.length)
          expectation.fulfill()
        } else {
          XCTFail("Comment is not as expected in _matchesInfo")
        }
      case .failure(let error):
        print(error)
        XCTFail("Failed to search with testSearchMatches")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  // MARK: Attributes to highlight

  func testSearchAttributesToHighlight() {

    let expectation = XCTestExpectation(description: "Search for Books using attributes to highlight")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = "Joaquim Manuel de Macedo"
    let attributesToHighlight = ["comment"]
    let parameters = SearchParameters(query: query, limit: limit, attributesToHighlight: attributesToHighlight)

    self.client.search(UID: self.uid, parameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 1)
        let book = documents.hits[0]
        XCTAssertEqual("A Moreninha", book.title)
        XCTAssertTrue(book.formatted!.comment!.contains("<em>Joaquim</em> <em>Manuel</em> <em>de</em> <em>Macedo</em>"))
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testSearchAttributesToHighlight")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  // MARK: Attributes to retrieve

  func testSearchAttributesToRetrieve() {

    let expectation = XCTestExpectation(description: "Search for Books using attributes to retrieve")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = "Joaquim Manuel de Macedo"
    let attributesToRetrieve = ["id", "title"]
    let parameters = SearchParameters(query: query, limit: limit, attributesToRetrieve: attributesToRetrieve)

    self.client.search(UID: self.uid, parameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 1)
        let book = documents.hits[0]
        XCTAssertEqual(1844, book.id)
        XCTAssertEqual("A Moreninha", book.title)
        XCTAssertNil(book.comment)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search with testSearchAttributesToRetrieve")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  // MARK: Filters

  private func configureFilters(_ completion: @escaping () -> Void) {

    let expectation = XCTestExpectation(description: "Configure filterable attributes")
    let filterableAttributes = ["genres", "author", "id"]

    self.client.updateFilterableAttributes(UID: self.uid, filterableAttributes) { result in

      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          expectation.fulfill()
          completion()
        }
      case .failure:
        XCTFail("Failed to update the settings")
      }

    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  func testSearchFilters() {

    let expectation = XCTestExpectation(description: "Search for Books using filter")
    configureFilters {
      typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
      let limit = 5
      let query = "french book"
      let filter = "id = 456"
      let parameters = SearchParameters(query: query, limit: limit, filter: filter)

      self.client.search(UID: self.uid, parameters) { (result: MeiliResult) in
        switch result {
        case .success(let documents):
          XCTAssertTrue(documents.query == query)
          XCTAssertTrue(documents.limit == limit)
          XCTAssertTrue(documents.hits.count == 1)
          let book = documents.hits[0]
          XCTAssertEqual(456, book.id)
          XCTAssertEqual("Le Petit Prince", book.title)
          XCTAssertEqual("A french book", book.comment)
          expectation.fulfill()
        case .failure(let error):
          print(error)
          XCTFail("Failed to search with testSearchFilters")
        }
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  func testSearchFiltersNotMatching() {

    let expectation = XCTestExpectation(description: "Search for Books using filters but the query and filters are not matching")

    configureFilters {
      typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
      let limit = 5
      let query = "Joaquim Manuel de Macedo"
      let filter = "id = 456"
      let parameters = SearchParameters(query: query, limit: limit, filter: filter)

      self.client.search(UID: self.uid, parameters) { (result: MeiliResult) in
        switch result {
        case .success(let documents):
          XCTAssertTrue(documents.query == query)
          XCTAssertTrue(documents.limit == limit)
          XCTAssertTrue(documents.hits.isEmpty)
          expectation.fulfill()
        case .failure:
          XCTFail("Failed to search with testSearchFiltersNotMatching")
        }
      }
    }
    self.wait(for: [expectation], timeout: 1.0)
  }

  func testSearchFacetsFilters() {

    let expectation = XCTestExpectation(description: "Search for Books using facets filters")

    configureFilters {

      typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
      let limit = 5
      let query = "A"
      let filter = "genres = Novel"
      let parameters = SearchParameters(query: query, limit: limit, filter: filter)

      self.client.search(UID: self.uid, parameters) { (result: MeiliResult) in
        switch result {
        case .success(let documents):
          XCTAssertTrue(documents.query == query)
          XCTAssertTrue(documents.limit == limit)
          XCTAssertTrue(documents.hits.count == 2)
          let moreninhaBook: Book = documents.hits.first { book in book.id == 1844 }!
          XCTAssertEqual("A Moreninha", moreninhaBook.title)
          let petitBook: Book = documents.hits.first { book in book.id == 456 }!
          XCTAssertEqual("Le Petit Prince", petitBook.title)
          expectation.fulfill()
        case .failure:
          XCTFail("Failed to search with testSearchFacetsFilters")
        }
      }

    }

    self.wait(for: [expectation], timeout: 2.0)
  }

  // MARK: Facets distribution

  func testSearchFacetsDistribution() {

    let expectation = XCTestExpectation(description: "Search for Books using facets distribution")

    configureFilters {

      typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
      let limit = 5
      let query = "A"
      let facetsDistribution = ["genres"]
      let parameters = SearchParameters(query: query, limit: limit, facetsDistribution: facetsDistribution)

      self.client.search(UID: self.uid, parameters) { (result: MeiliResult) in
        switch result {
        case .success(let documents):
          XCTAssertTrue(documents.query == query)
          XCTAssertTrue(documents.limit == limit)
          XCTAssertTrue(documents.hits.count == limit)

          let facetsDistribution = documents.facetsDistribution!

          let expected: [String: [String: Int]] = [
            "genres": [
              "Classic Regency nove": 1,
              "High fantasy‎": 1,
              "Fantasy": 2,
              "Novel": 2,
              "Bildungsroman": 1
            ]
          ]

          XCTAssertEqual(expected, facetsDistribution)

          expectation.fulfill()
        case .failure:
          XCTFail("Failed to search with testSearchFacetsDistribution")
        }
      }

    }

    self.wait(for: [expectation], timeout: 2.0)
  }

  func testSearchFacetsDistributionNullValue() {

    let expectation = XCTestExpectation(description: "Search for Books using facets distribution with 0 value")

    configureFilters {
      typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
      let limit = 5
      let query = "Petit Prince"
      let facetsDistribution = ["genres"]
      let filter = "genres = comedy"
      let parameters = SearchParameters(query: query, limit: limit, filter: filter, facetsDistribution: facetsDistribution)

      self.client.search(UID: self.uid, parameters) { (result: MeiliResult) in
        switch result {
        case .success(let documents):
          XCTAssertTrue(documents.query == query)
          XCTAssertTrue(documents.limit == limit)
          XCTAssertTrue(documents.hits.count == 0)

          let facetsDistribution = documents.facetsDistribution!
          XCTAssertEqual(["genres": [:]], facetsDistribution)

          expectation.fulfill()
        case .failure:
          XCTFail("Failed to search with testSearchFacetsDistribution")
        }
      }
    }
    self.wait(for: [expectation], timeout: 2.0)
  }

}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
