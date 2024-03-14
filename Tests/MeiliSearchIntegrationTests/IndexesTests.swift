@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class IndexesTests: XCTestCase {
  private var client: MeiliSearch!
  private var session: URLSessionProtocol!
  private let uid: String = "books_test"
  private var index: Indexes!

  override func setUpWithError() throws {
    try super.setUpWithError()

    if client == nil {
      session = URLSession(configuration: .ephemeral)
      client = try MeiliSearch(host: currentHost(), apiKey: "masterKey", session: session)
    }
    index = self.client.index(self.uid)

    let getIndexesExp = XCTestExpectation(description: "Try to get all indexes")

    self.client.getIndexes { result in
      switch result {
      case .success(let indexes):
        let asyncDeletegroup = DispatchGroup()
        for index in indexes.results {
          asyncDeletegroup.enter()
          self.client.deleteIndex(index.uid) { res in
            switch res {
            case .success:
              asyncDeletegroup.leave()
            case .failure(let error):
              dump(error)
              asyncDeletegroup.leave()
            }
          }
        }
        getIndexesExp.fulfill()
      case .failure(let error):
        dump(error)
        getIndexesExp.fulfill()
      }
    }
    self.wait(for: [getIndexesExp], timeout: TESTS_TIME_OUT)
  }

  func testCreateIndex() {
    let createExpectation = XCTestExpectation(description: "Create Movies index")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task, options: WaitOptions(timeOut: 10.0)) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("indexCreation", task.type.description)
            XCTAssertEqual(task.status, Task.Status.succeeded)
            createExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            createExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create an index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: TESTS_TIME_OUT)
  }

  func testCreateIndexThatAlreadyExists() {
    let deleteException = XCTestExpectation(description: "Delete Movies index")
    deleteIndex(client: self.client, uid: self.uid) { result in
      switch result {
      case .success:
        deleteException.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        deleteException.fulfill()
      }
    }
    self.wait(for: [deleteException], timeout: TESTS_TIME_OUT)

    let createExpectation = XCTestExpectation(description: "Create Movies index")
    createGenericIndex(client: self.client, uid: self.uid ) { result in
      switch result {
      case .success(let task):
        XCTAssertEqual("indexCreation", task.type.description)
        XCTAssertEqual(task.status, Task.Status.succeeded)
        createExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: TESTS_TIME_OUT)

    let create2ndIndexExpectation = XCTestExpectation(description: "Create Movies index that already exists and fail")
    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("indexCreation", task.type.description)
            XCTAssertEqual(task.status, Task.Status.failed)
            if let error = task.error {
              XCTAssertEqual(error.code, "index_already_exists")
            } else {
              XCTFail("Failed: Error code should be index_already_exists")
            }
            create2ndIndexExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            create2ndIndexExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create an index")
        create2ndIndexExpectation.fulfill()
      }
    }
    self.wait(for: [create2ndIndexExpectation], timeout: TESTS_TIME_OUT)

  }

  func testGetIndex() {

    let createExpectation = XCTestExpectation(description: "Create Movies index")
    createGenericIndex(client: self.client, uid: self.uid ) { result in
      switch result {
      case .success:
        createExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: TESTS_TIME_OUT)

    let getIndexExpectation = XCTestExpectation(description: "Get index")

    self.client.getIndex(self.uid) { result in
      switch result {
      case .success(let index):
        let stubIndex = self.client.index(self.uid)
        XCTAssertEqual(stubIndex.uid, index.uid)
        getIndexExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get index")
        getIndexExpectation.fulfill()
      }
    }

    self.wait(for: [getIndexExpectation], timeout: TESTS_TIME_OUT)
  }

  func testGetIndexes() {
    let createExpectation = XCTestExpectation(description: "Create Movies index")
    createGenericIndex(client: self.client, uid: self.uid) { result in
      switch result {
      case .success:
        createExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: TESTS_TIME_OUT)

    let expectation = XCTestExpectation(description: "Load indexes")

    self.client.getIndexes { result in
      switch result {
      case .success(let indexes):
        XCTAssertEqual(1, indexes.results.count)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get all Indexes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateIndexName() {
    let createExpectation = XCTestExpectation(description: "Create Movies index")
    createGenericIndex(client: self.client, uid: self.uid) { result in
      switch result {
      case .success:
        createExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: TESTS_TIME_OUT)

    // This tests should tests primary key when they are added to this function
    let updateExpectation = XCTestExpectation(description: "Update movie index")
    self.client.updateIndex(uid: self.uid, primaryKey: "random") { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("indexUpdate", task.type.description)
            XCTAssertEqual(task.status, Task.Status.succeeded)
            if case .indexUpdate(let details) = task.details, let primaryKey = details.primaryKey {
              XCTAssertEqual("random", primaryKey)
            } else {
              XCTFail("Primary key should exists in details field of task")
            }
            updateExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            updateExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to update index")
        updateExpectation.fulfill()
      }
    }
    self.wait(for: [updateExpectation], timeout: TESTS_TIME_OUT)
  }

  func testSwapIndex() async throws {
    let documents: [Movie] = [
      Movie(id: 123, title: "Pride and Prejudice", comment: "A great book"),
      Movie(id: 456, title: "Le Petit Prince", comment: "A french book"),
    ]

    // Remove indexes (if present)
    try await client.deleteIndex("indexA").wait(on: client)
    try await client.deleteIndex("indexB").wait(on: client)

    // Create destination index
    try await client.createIndex(uid: "indexA").wait(on: client)

    // Create source index
    try await client.createIndex(uid: "indexB").wait(on: client)
    try await client.index("indexB").addDocuments(documents: documents).wait(on: client)
    try await client.index("indexB").updateStopWords(["test"]).wait(on: client)

    // Verify indexA (destination) does not have any stop words or documents
    let stopWords: [String] = try await client.index("indexA").getStopWords()
    XCTAssertEqual(stopWords, [])

    let movies: DocumentsResults<Movie> = try await client.index("indexA").getDocuments()
    XCTAssertEqual(movies.total, 0)

    // Replace indexes
    let task = try await client.swapIndexes([("indexA", "indexB")]).wait(on: client)
    XCTAssertEqual(task.type, .indexSwap)

    guard case .indexSwap(let value) = task.details else {
      XCTFail("Task Not a Swap")
      return
    }

    XCTAssertEqual(value.swaps[0], .init(indexes: ["indexA", "indexB"]))

    // Verify indexA (now source) does have stop words and documents
    let stopWordsNew: [String] = try await client.index("indexA").getStopWords()
    XCTAssertEqual(stopWordsNew, ["test"])

    let moviesNew: DocumentsResults<Movie> = try await client.index("indexA").getDocuments()
    XCTAssertEqual(moviesNew.total, 2)
  }

  func testDeleteIndex() {

    let createExpectation = XCTestExpectation(description: "Create Movies index")
    createGenericIndex(client: self.client, uid: self.uid) { result in
      switch result {
      case .success:
        createExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: TESTS_TIME_OUT)

    let deleteException = XCTestExpectation(description: "Delete Movies index")
    deleteIndex(client: self.client, uid: self.uid) { result in
      switch result {
      case .success(let task):
        XCTAssertEqual("indexDeletion", task.type.description)
        XCTAssertEqual(task.status, Task.Status.succeeded)
        deleteException.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        deleteException.fulfill()
      }
    }
    self.wait(for: [deleteException], timeout: TESTS_TIME_OUT)
  }
}
