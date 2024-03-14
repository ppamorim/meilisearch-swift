@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

private let books: [Book] = [
  Book(id: 123, title: "Pride and Prejudice", comment: "A great book", genres: ["Classic Regency nove"]),
  Book(id: 456, title: "Le Petit Prince", comment: "A french book", genres: ["Novel"]),
  Book(id: 2, title: "Le Rouge et le Noir", comment: "Another french book", genres: ["Bildungsroman"]),
  Book(id: 1, title: "Alice In Wonderland", comment: "A weird book", genres: ["Fantasy"]),
  Book(id: 1344, title: "The Hobbit", comment: "An awesome book", genres: ["High fantasy"]),
  Book(id: 4, title: "Harry Potter and the Half-Blood Prince", comment: "The best book", genres: ["Fantasy"]),
  Book(id: 42, title: "The Hitchhiker's Guide to the Galaxy", genres: ["Novel"]),
  Book(id: 1844, title: "A Moreninha", comment: "A Book from Joaquim Manuel de Macedo", genres: ["Novel"]),
  Book(id: 94, title: "The Book Thief", comment: "By Markus Zusak", genres: ["Fictional"])
]

// swiftlint:disable force_unwrapping

private let nestedBooks: [NestedBook] = [
  NestedBook(id: 123, title: "Pride and Prejudice", info: InfoNested(comment: "A great book", reviewNb: 100), genres: ["Classic Regency nove"]),
  NestedBook(id: 456, title: "Le Petit Prince", info: InfoNested(comment: "A french book", reviewNb: 100), genres: ["Novel"]),
  NestedBook(id: 2, title: "Le Rouge et le Noir", info: InfoNested(comment: "Another french book", reviewNb: 100), genres: ["Bildungsroman"])
]

class SearchTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private var nestedIndex: Indexes!
  private var session: URLSessionProtocol!
  private let uid: String = "books_test"
  private let nested_uid: String = "nested_books_test"

  // MARK: Setup

  override func setUpWithError() throws {
    try super.setUpWithError()

    session = URLSession(configuration: .ephemeral)
    client = try MeiliSearch(host: currentHost(), apiKey: "masterKey", session: session)
    index = self.client.index(self.uid)
    nestedIndex = self.client.index(self.nested_uid)

    let addDocExpectation = XCTestExpectation(description: "Add documents")

    addDocuments(client: self.client, uid: self.uid, dataset: books, primaryKey: nil) { result in
      switch result {
      case .success:
        addDocExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        addDocExpectation.fulfill()
      }
    }
    self.wait(for: [addDocExpectation], timeout: TESTS_TIME_OUT)
    let addNestedDocExpectation = XCTestExpectation(description: "Add documents")
    addDocuments(client: self.client, uid: self.nested_uid, dataset: nestedBooks, primaryKey: nil) { result in
      switch result {
      case .success:
        addNestedDocExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        addNestedDocExpectation.fulfill()
      }
    }
    self.wait(for: [addNestedDocExpectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Basic search
  func testBasicSearch() {
    let expectation = XCTestExpectation(description: "Search for Books with query")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let query = "Moreninha"

    self.index.search(SearchParameters(query: query)) { (result: MeiliResult) in
      switch result {
      case .success(let response):
        let result = response as! SearchResult<Book>

        XCTAssertEqual(result.estimatedTotalHits, 1)
        XCTAssertEqual(result.query, query)
        XCTAssertEqual(result.limit, 20)
        XCTAssertEqual(result.hits.count, 1)
        XCTAssertNil(result.facetStats)
        if response.hits.count > 0 {
          XCTAssertEqual("A Moreninha", response.hits[0].title)
          XCTAssertNil(response.hits[0].formatted)
        } else {
          XCTFail("Failed to find hits in the response")
        }
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testBasicSearch")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Attributes to search on
  func testAttributesSearchOn() {
    let expectation = XCTestExpectation(description: "Search for Books with limited attributes")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let query = "book"
    // even though multiple books have the word "book" in the comment, only one has "book" in the title.

    self.index.search(SearchParameters(query: query, attributesToSearchOn: ["title"])) { (result: MeiliResult) in
      switch result {
      case .success(let response):
        let result = response as! SearchResult<Book>

        XCTAssertEqual(result.estimatedTotalHits, 1)
        XCTAssertEqual(result.query, query)
        XCTAssertEqual(result.limit, 20)
        XCTAssertEqual(result.hits.count, 1)
        if response.hits.count > 0 {
          XCTAssertEqual("The Book Thief", response.hits[0].title)
          XCTAssertNil(response.hits[0].formatted)
        } else {
          XCTFail("Failed to find hits in the response")
        }
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testAttributesSearchOn")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Search ranking
  func testSearchRankingScore() {
    let expectation = XCTestExpectation(description: "Search for Books with query")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let query = "Moreninha"

    self.index.search(SearchParameters(query: query, showRankingScore: true)) { (result: MeiliResult) in
      switch result {
      case .success(let response):
        let result = response as! SearchResult<Book>
        XCTAssertEqual(result.hits.count, 1)
        XCTAssertGreaterThan(result.hits[0].rankingScore ?? 0, 0.1)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchRankingScore")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testSearchBoxEncodingWithScore() {
    let expectation = XCTestExpectation(description: "Search for Books with query")

    let expectedValue = """
    {"hits":[{"_rankingScore":0.5,"comment":"A Book from Joaquim Manuel de Macedo","genres":["Novel"],"id":1844,"title":"A Moreninha"}],"processingTimeMs":0,"query":"Moreninha"}
    """

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let query = "Moreninha"

    self.index.search(SearchParameters(query: query, showRankingScore: true)) { (result: MeiliResult) in
      switch result {
      case .success(let response):
        do {
          // the ranking score and time can change for many reasons, of which is not relevant here. we set it to a constant to test the encoding.
          response.processingTimeMs = 0
          response.hits[0].rankingScore = 0.5
          let encoder = JSONEncoder()
          encoder.outputFormatting = .sortedKeys
          let data = try encoder.encode(response)
          XCTAssertEqual(String(decoding: data, as: UTF8.self), expectedValue)
        } catch {
          XCTFail("Failed to encode search result")
        }
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchBoxEncodingWithScore")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testSearchBoxEncodingWithoutScore() {
    let expectation = XCTestExpectation(description: "Search for Books with query")

    let expectedValue = """
    {"hits":[{"comment":"A Book from Joaquim Manuel de Macedo","genres":["Novel"],"id":1844,"title":"A Moreninha"}],"processingTimeMs":0,"query":"Moreninha"}
    """

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let query = "Moreninha"

    self.index.search(SearchParameters(query: query, showRankingScore: false)) { (result: MeiliResult) in
      switch result {
      case .success(let response):
        do {
          let encoder = JSONEncoder()
          encoder.outputFormatting = .sortedKeys
          response.processingTimeMs = 0
          let data = try encoder.encode(response)
          XCTAssertEqual(String(decoding: data, as: UTF8.self), expectedValue)
        } catch {
          XCTFail("Failed to encode search result")
        }
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchBoxEncodingWithoutScore")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Basic search with finite pagination
  func testBasicSearchWithFinitePagination() {
    let expectation = XCTestExpectation(description: "Search for Books with finite pagination")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let query = "Moreninha"

    self.index.search(SearchParameters(query: query, hitsPerPage: 1)) { (result: MeiliResult) in
      switch result {
      case .success(let response):
        let result = response as! FiniteSearchResult<Book>

        XCTAssertEqual(result.totalHits, 1)
        XCTAssertEqual(result.query, query)
        XCTAssertEqual(result.hitsPerPage, 1)
        XCTAssertEqual(result.hits.count, 1)
        if response.hits.count > 0 {
          XCTAssertEqual("A Moreninha", response.hits[0].title)
          XCTAssertNil(response.hits[0].formatted)
        } else {
          XCTFail("Failed to find hits in the response")
        }
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testBasicSearch")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

   // MARK: Nested search
  func testNestedSearch() {
    let expectation = XCTestExpectation(description: "Search in Nested Books")

    typealias MeiliResult = Result<Searchable<NestedBook>, Swift.Error>
    let query = "A french book"

    self.nestedIndex.search(SearchParameters(query: query)) { (result: MeiliResult) in
      switch result {
      case .success(let response):
        if response.hits.count > 0 {
          XCTAssertEqual("A french book", response.hits[0].info.comment)
        } else {
          XCTFail("Failed to find hits in the response")
        }
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search in nested books")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testBasicSearchWithNoQuery() {
    let expectation = XCTestExpectation(description: "Search for Books without query")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>

    self.index.search(SearchParameters(query: nil)) { (result: MeiliResult) in
      switch result {
      case .success(let response):
        let result = response as! SearchResult<Book>

        XCTAssertEqual("", response.query)
        XCTAssertEqual(20, result.limit)
        XCTAssertEqual(books.count, response.hits.count)
        XCTAssertEqual("Pride and Prejudice", response.hits[0].title)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testBasicSearchWithNoQuery")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Phrase search

  func testPhraseSearch() {
    let expectation = XCTestExpectation(description: "Search for Books using phrase search")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let query = "A \"great book\""

    self.index.search(SearchParameters(query: query)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(documents.query, query)
        XCTAssertEqual(result.limit, 20)
        XCTAssertEqual(documents.hits.count, 1)
        XCTAssertEqual("Pride and Prejudice", documents.hits[0].title)
        XCTAssertNil(documents.hits[0].formatted)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testPhraseSearch")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Limit

  func testSearchLimit() {
    let expectation = XCTestExpectation(description: "Search for Books using limit")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 5
    let query = "Moreninha"

    self.index.search(SearchParameters(query: query, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(documents.query, query)
        XCTAssertEqual(result.limit, limit)
        XCTAssertEqual(documents.hits.count, 1)
        XCTAssertEqual("A Moreninha", documents.hits[0].title)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchLimit")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testSearchZeroLimit() {
    let expectation = XCTestExpectation(description: "Search for Books using zero limit")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 0
    let query = "A Moreninha"

    self.index.search(SearchParameters(query: query, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(documents.query, query)
        XCTAssertEqual(result.limit, limit)
        XCTAssertTrue(documents.hits.isEmpty)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchZeroLimit")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testSearchLimitBiggerThanNumberOfBooks() {
    let expectation = XCTestExpectation(description: "Search for Books using limit bigger than the number of books stored")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 5
    let query = "A"

    self.index.search(SearchParameters(query: query, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(documents.query, query)
        XCTAssertEqual(result.limit, limit)
        XCTAssertEqual(documents.hits.count, limit)
        XCTAssertNil(documents.hits[0].formatted)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchLimitBiggerThanNumberOfBooks")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testSearchLimitEmptySearch() {
    let expectation = XCTestExpectation(description: "Search for Books using limit but nothing in the query")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 5
    let query = ""

    self.index.search(SearchParameters(query: query, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(documents.query, query)
        XCTAssertEqual(result.limit, limit)
        XCTAssertEqual(documents.hits.count, 5)
        XCTAssertNil(documents.hits[0].formatted)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchLimitEmptySearch")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Offset

  func testSearchOffset() {
    let expectation = XCTestExpectation(description: "Search for Books using offset")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 2
    let offset = 2
    let query = "A"

    self.index.search(SearchParameters(query: query, offset: offset, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(documents.query, query)
        XCTAssertEqual(result.limit, limit)
        XCTAssertEqual(result.offset, offset)
        XCTAssertEqual(documents.hits.count, 2)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchOffset")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testSearchOffsetZero() {
    let expectation = XCTestExpectation(description: "Search for Books using zero offset")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 2
    let offset = 0
    let query = "A"

    self.index.search(SearchParameters(query: query, offset: offset, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(documents.query, query)
        XCTAssertEqual(result.limit, limit)
        XCTAssertEqual(result.offset, offset)
        XCTAssertEqual(documents.hits.count, 2)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchOffsetZero")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testSearchOffsetLastPage() {
    let expectation = XCTestExpectation(description: "Search for Books using a offset at the last page")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 2
    let offset = 6
    let query = "A"

    self.index.search(SearchParameters(query: query, offset: offset, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(documents.query, query)
        XCTAssertEqual(result.limit, limit)
        XCTAssertEqual(result.offset, offset)
        XCTAssertEqual(documents.hits.count, 1)
        XCTAssertNil(documents.hits[0].formatted)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchOffsetLastPage")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Attributes to crop

  func testSearchAttributesToCrop() {
    let expectation = XCTestExpectation(description: "Search for Books using attributes to crop")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 2
    let query = "de Macedo"
    let attributesToCrop = ["comment"]
    let cropLength = 5
    let searchParameters = SearchParameters(query: query, limit: limit, attributesToCrop: attributesToCrop, cropLength: cropLength)

    self.index.search(searchParameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(result.limit, limit)
        XCTAssertEqual(documents.hits.count, 1)
        let book: SearchHit<Book> = documents.hits[0]
        XCTAssertEqual("…from Joaquim Manuel de Macedo", book.formatted!.comment!)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchAttributesToCrop")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

   // MARK: Crop Marker

  func testSearchCropMarker() {
    let expectation = XCTestExpectation(description: "Search for Books with a custom crop marker")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let query = "Manuel"
    let attributesToCrop = ["comment"]
    let cropLength = 2
    let cropMarker = "(ꈍᴗꈍ)"
    let searchParameters = SearchParameters(query: query, attributesToCrop: attributesToCrop, cropLength: cropLength, cropMarker: cropMarker)

    self.index.search(searchParameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let book: SearchHit<Book> = documents.hits[0]
        XCTAssertEqual("(ꈍᴗꈍ)Joaquim Manuel(ꈍᴗꈍ)", book.formatted!.comment!)
        expectation.fulfill()
      case .failure(let error):
        print(error)
        XCTFail("Failed to search with a custom crop marker")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Crop length

  func testSearchCropLength() {
    let expectation = XCTestExpectation(description: "Search for Books using default crop length")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 2
    let query = "book"
    let attributesToCrop = ["comment"]
    let cropLength = 5
    let searchParameters = SearchParameters(query: query, limit: limit, attributesToCrop: attributesToCrop, cropLength: cropLength)

    self.index.search(searchParameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(result.limit, limit)
        XCTAssertEqual(documents.hits.count, 2)

        let moreninhaBook: SearchHit<Book> = documents.hits.first(where: { book in book.id == 1844 })!
        XCTAssertEqual("A Book from Joaquim Manuel…", moreninhaBook.formatted!.comment!)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchCropLength")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Matches tests

  func testSearchMatches() {
    let expectation = XCTestExpectation(description: "Search for Books using showMatchesPosition")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 5
    let query = "Moreninha"
    let parameters = SearchParameters(query: query, limit: limit, showMatchesPosition: true)

    self.index.search(parameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(documents.query, query)
        XCTAssertEqual(result.limit, limit)
        XCTAssertEqual(documents.hits.count, 1)
        let book = documents.hits[0]
        XCTAssertEqual("A Moreninha", book.title)

        let matchesInfo = book.matchesInfo!
        if let titleMatches = matchesInfo.title {
          let firstMatch = titleMatches[0]
          XCTAssertEqual(2, firstMatch.start)
          XCTAssertEqual(9, firstMatch.length)
        } else {
          XCTFail("Comment is not as expected in _matchesInfo")
        }
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchMatches")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Attributes to highlight

  func testSearchAttributesToHighlight() {
    let expectation = XCTestExpectation(description: "Search for Books using attributes to highlight")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 5
    let query = "Joaquim Manuel de Macedo"
    let attributesToHighlight = ["comment"]
    let parameters = SearchParameters(query: query, limit: limit, attributesToHighlight: attributesToHighlight)

    self.index.search(parameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(documents.query, query)
        XCTAssertEqual(result.limit, limit)
        XCTAssertEqual(documents.hits.count, 1)
        let book = documents.hits[0]
        XCTAssertEqual("A Moreninha", book.title)
        XCTAssertTrue(book.formatted!.comment!.contains("<em>Joaquim</em> <em>Manuel</em> <em>de</em> <em>Macedo</em>"))
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchAttributesToHighlight")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Attributes to highlight

  func testSearchPrePostHighlightTags() {
    let expectation = XCTestExpectation(description: "Search for Books using custom pre and post highlight tags")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let query = "Joaquim Manuel de Macedo"
    let attributesToHighlight = ["comment"]
    let highlightPreTag = "(⊃｡•́‿•̀｡)⊃ "
    let highlightPostTag = " ⊂(´• ω •`⊂)"
    let parameters = SearchParameters(query: query, attributesToHighlight: attributesToHighlight, highlightPreTag: highlightPreTag, highlightPostTag: highlightPostTag)

    self.index.search(parameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let book = documents.hits[0]
        XCTAssertTrue(book.formatted!.comment!.contains("(⊃｡•́‿•̀｡)⊃ Joaquim ⊂(´• ω •`⊂) (⊃｡•́‿•̀｡)⊃ Manuel ⊂(´• ω •`⊂) (⊃｡•́‿•̀｡)⊃ de ⊂(´• ω •`⊂) (⊃｡•́‿•̀｡)⊃ Macedo ⊂(´• ω •`⊂)"))
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search using custom pre and post highlight tags")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Attributes to retrieve

  func testSearchAttributesToRetrieve() {
    let expectation = XCTestExpectation(description: "Search for Books using attributes to retrieve")

    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 5
    let query = "Joaquim Manuel de Macedo"
    let attributesToRetrieve = ["id", "title"]
    let parameters = SearchParameters(query: query, limit: limit, attributesToRetrieve: attributesToRetrieve)

    self.index.search(parameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        let result = documents as! SearchResult<Book>

        XCTAssertEqual(documents.query, query)
        XCTAssertEqual(result.limit, limit)
        XCTAssertEqual(documents.hits.count, 1)
        let book = documents.hits[0]
        XCTAssertEqual(1844, book.id)
        XCTAssertEqual("A Moreninha", book.title)
        XCTAssertNil(book.comment)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchAttributesToRetrieve")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Filters

  private func configureFilters(_ completion: @escaping (Result<(), Swift.Error>) -> Void) {
    let filterableAttributes = ["genres", "author", "id"]
    let settings = Setting(
      rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"],
      searchableAttributes: ["*"],
      displayedAttributes: ["*"],
      stopWords: ["the", "a"],
      synonyms: [:],
      distinctAttribute: nil,
      filterableAttributes: filterableAttributes,
      sortableAttributes: ["id"]
    )

    self.index.updateSettings(settings) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task, options: WaitOptions(timeOut: 10.0)) { result in
          switch result {
          case .success:
            completion(.success(()))
          case .failure(let error):
            dump(error)
            completion(.failure(error))
          }
        }
      case .failure(let error):
        dump(error)
        completion(.failure(error))
      }
    }
  }

  func testSearchFilters() {
    let expectation = XCTestExpectation(description: "Search for Books using filter")
    typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
    let limit = 5
    let query = "french book"
    let filter = "id = 456"
    let parameters = SearchParameters(query: query, limit: limit, filter: filter)

    configureFilters { result in
      switch result {
      case .success:
        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            let result = documents as! SearchResult<Book>

            XCTAssertEqual(documents.query, query)
            XCTAssertEqual(result.limit, limit)
            XCTAssertEqual(documents.hits.count, 1)
            let book = documents.hits[0]
            XCTAssertEqual(456, book.id)
            XCTAssertEqual("Le Petit Prince", book.title)
            XCTAssertEqual("A french book", book.comment)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with testSearchFilters")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testSearchSorting() {
    let expectation = XCTestExpectation(description: "Search for Books using sort on id")
    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
        let query = ""
        let sort = ["id:asc"]
        let parameters = SearchParameters(query: query, sort: sort)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            XCTAssertEqual(documents.query, query)
            let book = documents.hits[0]
            XCTAssertEqual(1, book.id)
            XCTAssertEqual("Alice In Wonderland", book.title)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with sorting parameter")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testSearchFiltersNotMatching() {
    let expectation = XCTestExpectation(description: "Search for Books using filters but the query and filters are not matching")

    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
        let limit = 5
        let query = "Joaquim Manuel de Macedo"
        let filter = "id = 456"
        let parameters = SearchParameters(query: query, limit: limit, filter: filter)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            let result = documents as! SearchResult<Book>

            XCTAssertEqual(documents.query, query)
            XCTAssertEqual(result.limit, limit)
            XCTAssertTrue(documents.hits.isEmpty)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with testSearchFiltersNotMatching")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchFilters")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testSearchFacetsFilters() {
    let expectation = XCTestExpectation(description: "Search for Books using facets filters")

    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
        let limit = 5
        let query = "A"
        let filter = "genres = Fantasy"
        let parameters = SearchParameters(query: query, limit: limit, filter: filter)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            let result = documents as! SearchResult<Book>

            XCTAssertEqual(documents.query, query)
            XCTAssertEqual(result.limit, limit)
            XCTAssertEqual(documents.hits.count, 2)

            XCTAssertEqual(documents.hits.compactMap { $0.title }, ["Alice In Wonderland", "Harry Potter and the Half-Blood Prince"])

            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with testSearchFacetsFilters")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: 2.0)
  }

  func testSearchFilterWithEmptySpace() {
    let expectation = XCTestExpectation(description: "Search for Books using filters with a space in the value")

    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<Searchable<Book>, Error>

        let query = ""
        let limit = 5
        let filter = "genres = 'High fantasy'"
        let parameters = SearchParameters(query: query, limit: limit, filter: filter)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            let result = documents as! SearchResult<Book>

            XCTAssertEqual(documents.query, query)
            XCTAssertEqual(result.limit, limit)
            XCTAssertEqual(documents.hits.count, 1)
            guard let book: SearchHit<Book> = documents.hits.first(where: { book in book.id == 1344 }) else {
              XCTFail("Failed to search with testSearchFilterWithEmptySpace")
              expectation.fulfill()
              return
            }
            XCTAssertEqual("The Hobbit", book.title)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with testSearchFilterWithEmptySpace")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Facet distribution

  func testSearchFacetDistribution() {
    let expectation = XCTestExpectation(description: "Search for Books using facets")

    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
        let limit = 5
        let query = "A"
        let facets = ["genres"]
        let parameters = SearchParameters(query: query, limit: limit, facets: facets)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            let result = documents as! SearchResult<Book>

            XCTAssertEqual(documents.query, query)
            XCTAssertEqual(result.limit, limit)
            XCTAssertEqual(documents.hits.count, limit)

            let facetDistribution = documents.facetDistribution!
            let expected: [String: [String: Int]] = [
              "genres": [
                "Bildungsroman": 1,
                "Classic Regency nove": 1,
                "Fantasy": 2,
                "High fantasy": 1,
                "Novel": 2
              ]
            ]

            XCTAssertEqual(facetDistribution["genres"]?.keys.sorted(), expected["genres"]?.keys.sorted())
            XCTAssertEqual(facetDistribution["genres"]?.values.sorted(), expected["genres"]?.values.sorted())
            XCTAssertEqual(documents.facetStats, [:])

            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with testSearchFacetDistribution")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 2.0)
  }

  func testSearchFacetDistributionNullValue() {
    let expectation = XCTestExpectation(description: "Search for Books using facets with 0 value")

    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
        let limit = 5
        let query = "Petit Prince"
        let facets = ["genres"]
        let filter = "genres = comedy"
        let parameters = SearchParameters(query: query, limit: limit, filter: filter, facets: facets)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            let result = documents as! SearchResult<Book>

            XCTAssertEqual(documents.query, query)
            XCTAssertEqual(result.limit, limit)
            XCTAssertEqual(documents.hits.count, 0)
            let facetDistribution = documents.facetDistribution!
            XCTAssertEqual(["genres": [:]], facetDistribution)

            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with testSearchFacetDistribution")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: 2.0)
  }

  // MARK: Facet stats

  func testSearchFacetStats() {
    let expectation = XCTestExpectation(description: "Search for Books using facets")

    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<Searchable<Book>, Swift.Error>
        let limit = 5
        let query = "A"
        let facets = ["id"]
        let parameters = SearchParameters(query: query, limit: limit, facets: facets)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            let result = documents as! SearchResult<Book>

            XCTAssertEqual(documents.query, query)
            XCTAssertEqual(result.limit, limit)
            XCTAssertEqual(documents.hits.count, limit)

            XCTAssertEqual(documents.facetStats?["id"]?.min, 1)
            XCTAssertEqual(documents.facetStats?["id"]?.max, 1844)

            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with testSearchFacetStats")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 2.0)
  }
}
// swiftlint:enable force_unwrapping
