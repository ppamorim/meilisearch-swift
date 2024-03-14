@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

// swiftlint:disable force_unwrapping

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
  private var index: Indexes!
  private var session: URLSessionProtocol!
  private let uid: String = "books_test"

  override func setUpWithError() throws {
    try super.setUpWithError()
    session = URLSession(configuration: .ephemeral)
    client = try MeiliSearch(host: currentHost(), apiKey: "masterKey", session: session)
    index = self.client.index(self.uid)
    let expectation = XCTestExpectation(description: "Create index if it does not exist")
    self.client.createIndex(uid: uid) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success:
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testAddDocuments() {
    let expectation = XCTestExpectation(description: "Add documents")

    // Add document
    self.index.addDocuments(
      documents: movies,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("documentAdditionOrUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .documentAdditionOrUpdate(let details) = task.details {
              XCTAssertEqual(8, details.indexedDocuments)
              XCTAssertEqual(8, details.receivedDocuments)
            } else {
              XCTFail("documentAdditionOrUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to add documents")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testAddDocumentsWithNoPrimaryKey() {
    let expectation = XCTestExpectation(description: "Add documents with no primary key")
    self.index.addDocuments(
      documents: movies,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("documentAdditionOrUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to fetch documents")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to add documents")
        expectation.fulfill()
      }

    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testGetDocumentsWithParameters() {
    let expectation = XCTestExpectation(description: "Add or replace Movies document")

    self.index.addDocuments(
      documents: movies,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentAdditionOrUpdate", task.type.description)

            self.index.getDocuments(params: DocumentsQuery(limit: 1, offset: 1, fields: ["id", "title"])) { (result: Result<DocumentsResults<Movie>, Swift.Error>) in
              switch result {
              case .success(let movies):
                let returnedMovie = movies.results[0]

                XCTAssertEqual(movies.results.count, 1)
                XCTAssertEqual(returnedMovie.id, 456)
                XCTAssertEqual(returnedMovie.title, "Le Petit Prince")
                XCTAssertEqual(returnedMovie.comment, nil)
                expectation.fulfill()
              case .failure:
                XCTFail("Failed to fetch documents")
                expectation.fulfill()
              }
            }
          case .failure:
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to add documents")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testGetOneDocumentAndFail() {
    let expectation = XCTestExpectation(description: "Get one document and fail")
    self.index.getDocument("123456") { (result: Result<Movie, Swift.Error>) in
      switch result {
      case .success:
        XCTFail("Document has been found while it should not have")
        expectation.fulfill()
      case .failure:
        expectation.fulfill()
      }

    }
    self.wait(for: [expectation], timeout: 3.0)
  }

  func testAddAndGetOneDocumentWithIntIdentifierAndSucceed() throws {
    let movie = Movie(id: 10, title: "test", comment: "test movie")
    let documents: Data = try JSONEncoder().encode([movie])
    let expectation = XCTestExpectation(description: "Add or replace Movies document")

    self.index.addDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentAdditionOrUpdate", task.type.description)
            self.index.getDocument(10
            ) { (result: Result<Movie, Swift.Error>) in
              switch result {
              case .success(let returnedMovie):
                XCTAssertEqual(movie, returnedMovie)
                expectation.fulfill()
              case .failure(let error):
                dump(error)
                XCTFail("Failed to fetch one document")
                expectation.fulfill()
              }
            }
          case .failure:
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to add documents")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testAddAndGetOneDocument() throws {
    let movie = Movie(id: 10, title: "test", comment: "test movie")
    let documents: Data = try JSONEncoder().encode([movie])
    let expectation = XCTestExpectation(description: "Add or replace Movies document")

    self.index.addDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentAdditionOrUpdate", task.type.description)
            self.index.getDocument("10"
            ) { (result: Result<Movie, Swift.Error>) in
              switch result {
              case .success(let returnedMovie):
                XCTAssertEqual(movie, returnedMovie)
                expectation.fulfill()
              case .failure(let error):
                dump(error)
                XCTFail("Failed to fetch one document")
                expectation.fulfill()
              }
            }
          case .failure:
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to add one document")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateDocument() throws {
    let identifier: Int = 1844
    let movie: Movie = movies.first(where: { (movie: Movie) in movie.id == identifier })!
    let documents: Data = try JSONEncoder().encode([movie])

    let expectation = XCTestExpectation(description: "Add or update Movies document")

    self.index.updateDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentAdditionOrUpdate", task.type.description)
            expectation.fulfill()
          case .failure:
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to update one document")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testDeleteOneDocument() throws {
    let documents: Data = try JSONEncoder().encode(movies)

    let expectation = XCTestExpectation(description: "Delete one Movie")
    self.index.addDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to add or replace Movies document")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)

    let deleteExpectation = XCTestExpectation(description: "Delete one Movie")
    self.index.deleteDocument("42") { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(taskUid: task.taskUid) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentDeletion", task.type.description)
            deleteExpectation.fulfill()
          case .failure:
            XCTFail("Failed to wait for task")
            deleteExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to delete one document")
        deleteExpectation.fulfill()
      }
    }
    self.wait(for: [deleteExpectation], timeout: 3.0)
  }

  func testDeleteAllDocuments() throws {
    let documents: Data = try JSONEncoder().encode(movies)

    let expectation = XCTestExpectation(description: "Add documents")
    self.index.addDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to add or replace Movies document")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)

    let deleteExpectation = XCTestExpectation(description: "Delete all documents")
    self.index.deleteAllDocuments { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentDeletion", task.type.description)
            if case .documentDeletion(let details) = task.details {
              // It's possible for this to number to be greater than 8 (the number of documents we have inserted) due
              // to other integration tests populating the shared index.
              XCTAssertGreaterThanOrEqual(details.deletedDocuments ?? -1, 8)
            } else {
              XCTFail("documentDeletion details should be set by task")
            }
            deleteExpectation.fulfill()
          case .failure:
            XCTFail("Failed to wait for task")
            deleteExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to delete all documents")
        deleteExpectation.fulfill()
      }
    }

    self.wait(for: [deleteExpectation], timeout: TESTS_TIME_OUT)
  }

  func testDeleteBatchDocuments() throws {
    let documents: Data = try JSONEncoder().encode(movies)

    let expectation = XCTestExpectation(description: "Add documents")
    self.index.addDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to add or replace Movies document")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)

    let deleteExpectation = XCTestExpectation(description: "Delete batch movies")
    let idsToDelete: [String] = ["2", "1", "4"]

    self.index.deleteBatchDocuments(idsToDelete) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentDeletion", task.type.description)
            deleteExpectation.fulfill()
          case .failure:
            XCTFail("Failed to wait for task")
            deleteExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to delete documents")
        deleteExpectation.fulfill()
      }
    }
    self.wait(for: [deleteExpectation], timeout: TESTS_TIME_OUT)
  }

  @available(*, deprecated, message: "Testing deprecated methods - marked deprecated to avoid additional warnings below.")
  func testDeprecatedDeleteBatchDocuments() throws {
    let documents: Data = try JSONEncoder().encode(movies)

    let expectation = XCTestExpectation(description: "Add documents")
    self.index.addDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to add or replace Movies document")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)

    let deleteExpectation = XCTestExpectation(description: "Delete batch movies with deprecated int ids")
    let idsToDelete: [Int] = [2, 1, 4]

    self.index.deleteBatchDocuments(idsToDelete) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentDeletion", task.type.description)
            deleteExpectation.fulfill()
          case .failure:
            XCTFail("Failed to wait for task")
            deleteExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to delete documents")
        deleteExpectation.fulfill()
      }
    }
    self.wait(for: [deleteExpectation], timeout: TESTS_TIME_OUT)
  }
}
// swiftlint:enable force_unwrapping
