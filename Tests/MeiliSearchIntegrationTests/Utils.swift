import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
import XCTest
@testable import MeiliSearch
@testable import MeiliSearchCore

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

public let TESTS_TIME_OUT = 10.0

public func currentHost() -> String {
  ProcessInfo.processInfo.environment["MEILISEARCH_URL"] ?? "http://localhost:7700"
}

public func waitForTask(
  _ client: MeiliSearch,
  _ uid: String,
  _ task: Task,
  _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
  func request() {
    client.index(uid).getTask(taskUid: task.uid) { result in
      switch result {
      case .success(let taskRes):
        if taskRes.status == Task.Status.succeeded || taskRes.status == Task.Status.failed {
          completion(.success(taskRes))
          return
        }
        request()
      case .failure(let error):
        dump("wait for task utils fail")
        dump(error)
        completion(.failure(error))
      }
    }
  }
  request()
}

public func createGenericIndex(client: MeiliSearch, uid: String, _ completion: @escaping(Result<Task, Swift.Error>) -> Void) {
  client.deleteIndex(uid) { result in
    switch result {
    case .success:
      client.createIndex(uid: uid) { result in
        switch result {
        case .success(let task):
          client.waitForTask(taskUid: task.taskUid, options: WaitOptions(timeOut: 10.0)) { result in
            switch result {
            case .success(let task):
              completion(.success(task))
            case .failure(let error):
              completion(.failure(error))
            }
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
    case .failure(let error):
      completion(.failure(error))
    }
  }
}

public func deleteIndex(client: MeiliSearch, uid: String, _ completion: @escaping(Result<Task, Swift.Error>) -> Void) {
  client.deleteIndex(uid) { result in
    switch result {
    case .success(let task):
      client.waitForTask(taskUid: task.taskUid) { result in
        switch result {
        case .success(let task):
          completion(.success(task))
        case .failure(let error):
          completion(.failure(error))
        }
      }
    case .failure(let error):
      dump(error)
      completion(.failure(error))
    }
  }
}

public func addDocuments(client: MeiliSearch, uid: String, primaryKey: String?, _ completion: @escaping(Result<Task, Swift.Error>) -> Void) {
  let movie = Movie(id: 1, title: "test", comment: "test movie")
  addDocuments(client: client, uid: uid, dataset: [movie], primaryKey: primaryKey, completion)
}

public func addDocuments<T: Encodable>(client: MeiliSearch, uid: String, dataset: [T], primaryKey: String?, _ completion: @escaping(Result<Task, Swift.Error>) -> Void) {
  let jsonEncoder = JSONEncoder()

  let documents: Data
  do {
    documents = try jsonEncoder.encode(dataset)
  } catch {
    completion(.failure(error))
    return
  }
  let index = client.index(uid)

  client.deleteIndex(uid) { result in
    switch result {
    case .success:
      index.addDocuments(documents: documents, primaryKey: primaryKey) { result in
        switch result {
        case .success(let task):
          client.waitForTask(taskUid: task.taskUid) { result in
            switch result {
            case .success(let task):
              completion(.success(task))
            case .failure(let error):
              completion(.failure(error))
            }
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
    case .failure(let error):
      completion(.failure(error))
    }
  }
}
