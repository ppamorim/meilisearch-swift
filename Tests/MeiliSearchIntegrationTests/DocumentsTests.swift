@testable import MeiliSearch
import XCTest
import Foundation

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
private struct Movie: Codable, Equatable {

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

private let movies: [Movie] = [
  Movie(id: 123, title: "Pride and Prejudice", comment: "A great book"),
  Movie(id: 456, title: "Le Petit Prince", comment: "A french book"),
  Movie(id: 2, title: "Le Rouge et le Noir", comment: "Another french book"),
  Movie(id: 1, title: "Alice In Wonderland", comment: "A weird book"),
  Movie(id: 1344, title: "The Hobbit", comment: "An awesome book"),
  Movie(id: 4, title: "Harry Potter and the Half-Blood Prince", comment: "The best book"),
  Movie(id: 42, title: "The Hitchhiker's Guide to the Galaxy"),
  Movie(id: 1844, title: "A Moreninha", comment: "A Book from Joaquim Manuel de Macedo")
]

class DocumentsTests: XCTestCase {

  private var client: MeiliSearch!
  private let uid: String = "books_test"

  override func setUp() {
    super.setUp()

    if client == nil {
      client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey")
    }

    let expectation = XCTestExpectation(description: "Create index if it does not exist")

    self.client.deleteIndex(UID: uid) { _ in
      self.client.getOrCreateIndex(UID: self.uid) { result in
        switch result {
        case .success:
          break
        case .failure(let error):
          print(error)
        }
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testAddAndGetDocuments() {

    let expectation = XCTestExpectation(description: "Add or replace Movies document")

    self.client.addDocuments(
      UID: self.uid,
      documents: movies,
      primaryKey: nil
    ) { result in

      switch result {
      case .success(let update):

        XCTAssertEqual(Update(updateId: 0), update)

        waitForPendingUpdate(self.client, self.uid, update) {

          self.client.getDocuments(
            UID: self.uid
          ) { (result: Result<[Movie], Swift.Error>) in
            switch result {
            case .success(let returnedMovies):
              movies.forEach { (movie: Movie) in
                XCTAssertTrue(returnedMovies.contains(movie))
              }
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }
    self.wait(for: [expectation], timeout: 5.0)
  }

  func testAddAndGetDocumentsEmptyParams() {
    let expectation = XCTestExpectation(description: "Add or replace Movies document")

    self.client.addDocuments(
      UID: self.uid,
      documents: movies,
      primaryKey: nil
    ) { result in

      switch result {
      case .success(let update):
        XCTAssertEqual(Update(updateId: 0), update)
        waitForPendingUpdate(self.client, self.uid, update) {
          self.client.getDocuments(
            UID: self.uid,
            options: GetParameters()
          ) { (result: Result<[Movie], Swift.Error>) in
            switch result {
            case .success(let returnedMovies):
              movies.forEach { (movie: Movie) in
                XCTAssertTrue(returnedMovies.contains(movie))
              }
              XCTAssertEqual(movies.count, 8)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }
    self.wait(for: [expectation], timeout: 5.0)

  }

  func testGetDocumentsWithParameters() {
    let expectation = XCTestExpectation(description: "Add or replace Movies document")

    self.client.addDocuments(
      UID: self.uid,
      documents: movies,
      primaryKey: nil
    ) { result in

      switch result {
      case .success(let update):
        XCTAssertEqual(Update(updateId: 0), update)
        waitForPendingUpdate(self.client, self.uid, update) {
          self.client.getDocuments(
            UID: self.uid,
            options: GetParameters(offset: 1, limit: 1, attributesToRetrieve: ["id", "title"])
          ) { (result: Result<[Movie], Swift.Error>) in
            switch result {
            case .success(let returnedMovies):
              let returnedMovie = returnedMovies[0]
              XCTAssertEqual(returnedMovies.count, 1)
              XCTAssertEqual(returnedMovie.id, 123)
              XCTAssertEqual(returnedMovie.title, "Pride and Prejudice")
              XCTAssertEqual(returnedMovie.comment, nil)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }
    self.wait(for: [expectation], timeout: 5.0)
  }

  func testGetOneDocumentAndFail() {
    let getExpectation = XCTestExpectation(description: "Get one document and fail")
    self.client.getDocument(
      UID: self.uid,
      identifier: "123456"
    ) { (result: Result<Movie, Swift.Error>) in
      switch result {
      case .success:
        XCTFail("Document has been found while it should not have")
      case .failure:
        getExpectation.fulfill()
      }
    }
    self.wait(for: [getExpectation], timeout: 3.0)
  }

  func testAddAndGetOneDocumentWithIntIdentifierAndSucceed() {
    let movie: Movie = Movie(id: 10, title: "test", comment: "test movie")
    let documents: Data = try! JSONEncoder().encode([movie])

    let expectation = XCTestExpectation(description: "Add or replace Movies document")

    self.client.addDocuments(
      UID: self.uid,
      documents: documents,
      primaryKey: nil
    ) { result in

      switch result {

      case .success(let update):

        XCTAssertEqual(Update(updateId: 0), update)

        waitForPendingUpdate(self.client, self.uid, update) {

          self.client.getDocument(
            UID: self.uid,
            identifier: 10
          ) { (result: Result<Movie, Swift.Error>) in

            switch result {
            case .success(let returnedMovie):
              XCTAssertEqual(movie, returnedMovie)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()

          }

        }

      case .failure(let error):
        print(error)
        XCTFail()
        expectation.fulfill()
      }

    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testAddAndGetOneDocuments() {

    let movie: Movie = Movie(id: 10, title: "test", comment: "test movie")
    let documents: Data = try! JSONEncoder().encode([movie])

    let expectation = XCTestExpectation(description: "Add or replace Movies document")

    self.client.addDocuments(
      UID: self.uid,
      documents: documents,
      primaryKey: nil
    ) { result in

      switch result {

      case .success(let update):

        XCTAssertEqual(Update(updateId: 0), update)

        waitForPendingUpdate(self.client, self.uid, update) {

          self.client.getDocument(
            UID: self.uid,
            identifier: "10"
          ) { (result: Result<Movie, Swift.Error>) in

            switch result {
            case .success(let returnedMovie):
              XCTAssertEqual(movie, returnedMovie)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()

          }

        }

      case .failure(let error):
        print(error)
        XCTFail()
        expectation.fulfill()
      }

    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateAndGetDocuments() {

    let identifier: Int = 1844

    let movie: Movie = movies.first(where: { (movie: Movie) in movie.id == identifier })!
    let documents: Data = try! JSONEncoder().encode([movie])

    let expectation = XCTestExpectation(description: "Add or update Movies document")

    self.client.updateDocuments(
      UID: self.uid,
      documents: documents,
      primaryKey: nil
    ) { result in

      switch result {

      case .success(let update):

        XCTAssertEqual(Update(updateId: 0), update)

        waitForPendingUpdate(self.client, self.uid, update) {

          self.client.getDocument(
            UID: self.uid,
            identifier: "\(identifier)"
          ) { (result: Result<Movie, Swift.Error>) in

            switch result {
            case .success(let returnedMovie):
              XCTAssertEqual(movie, returnedMovie)
            case .failure(let error):
              print(error)
              XCTFail()
            }

            expectation.fulfill()
          }

        }

      case .failure(let error):
        print(error)
        XCTFail()
        expectation.fulfill()
      }

    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testDeleteOneDocument() {

    let documents: Data = try! JSONEncoder().encode(movies)

    let expectation = XCTestExpectation(description: "Delete one Movie")
    self.client.addDocuments(
      UID: self.uid,
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(Update(updateId: 0), update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to add or replace Movies document")
      }
    }
    self.wait(for: [expectation], timeout: 1.0)

    let deleteExpectation = XCTestExpectation(description: "Delete one Movie")
    self.client.deleteDocument(UID: self.uid, identifier: "42") { (result: Result<Update, Swift.Error>) in
      switch result {
      case .success(let update):
        XCTAssertEqual(Update(updateId: 1), update)
        deleteExpectation.fulfill()
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }
    self.wait(for: [deleteExpectation], timeout: 3.0)

    let getExpectation = XCTestExpectation(description: "Add or update Movies document")
    self.client.getDocument(
      UID: self.uid,
      identifier: "10"
    ) { (result: Result<Movie, Swift.Error>) in
      switch result {
      case .success:
        XCTFail("Movie should not exist")
      case .failure:
        getExpectation.fulfill()
      }
    }
    self.wait(for: [getExpectation], timeout: 3.0)

  }

  func testDeleteAllDocuments() {
    let documents: Data = try! JSONEncoder().encode(movies)

    let expectation = XCTestExpectation(description: "Delete one Movie")
    self.client.addDocuments(
      UID: self.uid,
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let update):

        XCTAssertEqual(Update(updateId: 0), update)

        waitForPendingUpdate(self.client, self.uid, update) {

          self.client.deleteAllDocuments(UID: self.uid) { (result: Result<Update, Swift.Error>) in
            switch result {
            case .success(let update):

              XCTAssertEqual(Update(updateId: 1), update)

              waitForPendingUpdate(self.client, self.uid, update) {

                self.client.getDocuments(
                  UID: self.uid
                ) { (result: Result<[Movie], Swift.Error>) in
                  switch result {
                  case .success(let results):
                    XCTAssertEqual([], results)
                    expectation.fulfill()
                  case .failure(let error):
                    print(error)
                    XCTFail()
                    expectation.fulfill()
                  }
                }

              }

            case .failure(let error):
              print(error)
              XCTFail()
              expectation.fulfill()
            }
          }

        }

      case .failure:
        XCTFail("Failed to add or replace Movies document")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testDeleteBatchDocuments() {

    let documents: Data = try! JSONEncoder().encode(movies)

    let expectation = XCTestExpectation(description: "Delete batch movies")

    self.client.addDocuments(
      UID: self.uid,
      documents: documents,
      primaryKey: nil
    ) { result in

      switch result {

      case .success(let update):

        XCTAssertEqual(Update(updateId: 0), update)

        waitForPendingUpdate(self.client, self.uid, update) {

          let idsToDelete: [Int] = [2, 1, 4]

          self.client.deleteBatchDocuments(UID: self.uid, documentsUID: idsToDelete) { (result: Result<Update, Swift.Error>) in
            switch result {

            case .success(let update):

              XCTAssertEqual(Update(updateId: 1), update)

              waitForPendingUpdate(self.client, self.uid, update) {

                self.client.getDocuments(
                  UID: self.uid
                ) { (result: Result<[Movie], Swift.Error>) in
                  switch result {
                  case .success(let results):
                    let filteredMovies: [Movie] = movies.filter { (movie: Movie) in !idsToDelete.contains(movie.id) }
                    XCTAssertEqual(filteredMovies.count, results.count)
                    expectation.fulfill()
                  case .failure(let error):
                    print(error)
                    XCTFail()
                  }
                }
              }

            case .failure(let error):
              print(error)
              XCTFail()
              expectation.fulfill()
            }
          }

        }

      case .failure:
        XCTFail("Failed to delete batch movies")
        expectation.fulfill()
      }

    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  static var allTests = [
    ("testAddAndGetDocuments", testAddAndGetDocuments),
    ("testAddAndGetDocumentsEmptyParams", testAddAndGetDocumentsEmptyParams),
    ("testGetOneDocumentAndFail", testGetOneDocumentAndFail),
    ("testAddAndGetOneDocumentWithIntIdentifierAndSucceed", testAddAndGetOneDocumentWithIntIdentifierAndSucceed),
    ("testAddAndGetOneDocuments", testAddAndGetOneDocuments),
    ("testUpdateAndGetDocuments", testUpdateAndGetDocuments),
    ("testDeleteOneDocument", testDeleteOneDocument),
    ("testDeleteAllDocuments", testDeleteAllDocuments),
    ("testDeleteBatchDocuments", testDeleteBatchDocuments)
  ]

}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
