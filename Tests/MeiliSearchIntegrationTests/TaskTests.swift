@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class TasksTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private var session: URLSessionProtocol!
  private let uid: String = "books_test"

  // MARK: Setup

  override func setUpWithError() throws {
    try super.setUpWithError()
    session = URLSession(configuration: .ephemeral)
    client = try MeiliSearch(host: currentHost(), apiKey: "masterKey", session: session)
    index = self.client.index(self.uid)
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
  }

  func testGetTaskIndex() {
    let addDocExpectation = XCTestExpectation(description: "Add documents")
    let movie = Movie(id: 1, title: "test", comment: "test movie")

    self.index.addDocuments(documents: [movie], primaryKey: nil) { result in
      switch result {
      case .success(let task):
        self.index.getTask(taskUid: task.taskUid) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(task.type.description, "documentAdditionOrUpdate")
            addDocExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Could not get task")
            addDocExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        addDocExpectation.fulfill()
      }
    }
    self.wait(for: [addDocExpectation], timeout: TESTS_TIME_OUT)
  }

  func testGetTasksIndex() {
    let expectation = XCTestExpectation(description: "List tasks from index")
    let indexUid = "\(self.uid)_\(UUID().uuidString)"

    self.client.createIndex(uid: indexUid) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(taskUid: task.taskUid, options: WaitOptions(timeOut: 10.0)) { result in
          switch result {
          case .success:
            let index = self.client.index(indexUid)
            index.getTasks { (result: Result<TasksResults, Swift.Error>) in
              switch result {
              case .success(let tasks):
                // Only one because index has been deleted and recreated
                XCTAssertEqual(tasks.results.count, 1)
                XCTAssertEqual(tasks.total, 1)
                XCTAssertNotNil(tasks.results[0].startedAt)
                XCTAssertNotNil(tasks.results[0].finishedAt)
                expectation.fulfill()
              case .failure(let error):
                dump(error)
                XCTFail("Failed to get tasks")
                expectation.fulfill()
              }
            }
          case .failure(let error):
            dump(error)
            XCTFail("Failed to create index to get tasks")
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index to get tasks")
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testGetTaskClient() {
    let addDocExpectation = XCTestExpectation(description: "Add documents")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let task):
        self.client.getTask(taskUid: task.taskUid) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(task.type.description, "indexCreation")
            addDocExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Could not get task")
            addDocExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        addDocExpectation.fulfill()
      }
    }
    self.wait(for: [addDocExpectation], timeout: TESTS_TIME_OUT)
  }

  func testGetTasksClient() {
    let addDocExpectation = XCTestExpectation(description: "Add documents")

    addDocuments(client: self.client, uid: self.uid, primaryKey: nil) { result in
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

    let expectation = XCTestExpectation(description: "Get all tasks of an index")
    self.client.getTasks(params: TasksQuery(beforeEnqueuedAt: Date.distantPast)) { (result: Result<TasksResults, Swift.Error>)  in
      switch result {
      case .success(let tasks):
        XCTAssertNotNil(tasks.results)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get tasks")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testCancelTask() {
    let addDocExpectation = XCTestExpectation(description: "Add documents")
    addDocuments(client: self.client, uid: self.uid, primaryKey: nil) { result in
      switch result {
      case .success(let task):
        self.client.cancelTasks(filter: .init(uids: [task.uid])) { _ in
          self.client.getTasks { result in
            switch result {
            case .success(let tasks):
              XCTAssertGreaterThanOrEqual(tasks.results.count, 2)
              XCTAssertEqual(tasks.results[0].type, .taskCancelation)
              XCTAssertEqual(tasks.results[1].type, .documentAdditionOrUpdate)
            case .failure(let error):
              dump(error)
              XCTFail("Failed to get tasks")
            }
            addDocExpectation.fulfill()
          }
        }

      case .failure:
        XCTFail("Failed to add document")
        addDocExpectation.fulfill()
      }
    }
    self.wait(for: [addDocExpectation], timeout: TESTS_TIME_OUT)
  }

  func testDeleteTask() {
    let addDocExpectation = XCTestExpectation(description: "Add documents")
    addDocuments(client: self.client, uid: self.uid, primaryKey: nil) { result in
      switch result {
      case .success(let task):
        self.client.deleteTasks(filter: .init(uids: [task.uid])) { result in
          switch result {
          case .success(let taskInfo):
            self.client.waitForTask(task: taskInfo) { _ in
              self.client.getTasks { result in
                switch result {
                case .success(let tasks):
                  XCTAssertEqual(tasks.results[0].type, .taskDeletion)
                  XCTAssertNotEqual(tasks.results[1].uid, task.uid)
                case .failure(let error):
                  dump(error)
                  XCTFail("Failed to get tasks")
                }

                addDocExpectation.fulfill()
              }
            }
          case .failure:
            XCTFail("Failed to delete document")
            addDocExpectation.fulfill()
          }
        }
      case .failure:
        XCTFail("Failed to add document")
        addDocExpectation.fulfill()
      }
    }
    self.wait(for: [addDocExpectation], timeout: TESTS_TIME_OUT)
  }

  func testWaitForTask() {
    let createIndexExpectation = XCTestExpectation(description: "Add documents")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task, options: WaitOptions(timeOut: 1, interval: 0.5)) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(task.type.description, "indexCreation")
            createIndexExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Could not get task")
            createIndexExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        createIndexExpectation.fulfill()
      }
    }
    self.wait(for: [createIndexExpectation], timeout: TESTS_TIME_OUT)
  }

  func testWaitForTaskUid() {
    let createIndexExpectation = XCTestExpectation(description: "Add documents")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(taskUid: task.taskUid, options: WaitOptions(timeOut: 1, interval: 0.5)) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(task.type.description, "indexCreation")
            createIndexExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Could not get task")
            createIndexExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        createIndexExpectation.fulfill()
      }
    }
    self.wait(for: [createIndexExpectation], timeout: TESTS_TIME_OUT)
  }
}
