import Foundation
import MeiliSearchCore

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension MeiliSearch {
  /**
   See `createIndex(uid:primaryKey:_:)`
   */
  public func createIndex(uid: String, primaryKey: String? = nil) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.createIndex(uid: uid, primaryKey: primaryKey) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getIndex(_:_:)`
   */
  public func getIndex(_ uid: String) async throws -> Index {
    try await withCheckedThrowingContinuation { continuation in
      self.getIndex(uid) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getIndexes(params:_:)`
   */
  public func getIndexes(params: IndexesQuery? = nil) async throws -> IndexesResults {
    try await withCheckedThrowingContinuation { continuation in
      self.getIndexes(params: params) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateIndex(uid:primaryKey:_:)`
   */
  public func updateIndex(uid: String, primaryKey: String) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateIndex(uid: uid, primaryKey: primaryKey) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `deleteIndex(_:_:)`
   */
  public func deleteIndex(_ uid: String) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.deleteIndex(uid) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `swapIndexes(_:_:)`
   */
  public func swapIndexes(_ pairs: [(String, String)]) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.swapIndexes(pairs) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `waitForTask(taskUid:options:_:)`
   */
  public func waitForTask(taskUid: Int, options: WaitOptions? = nil) async throws -> Task {
    try await withCheckedThrowingContinuation { continuation in
      self.waitForTask(taskUid: taskUid, options: options) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `waitForTask(task:options:_:)`
   */
  public func waitForTask(task: TaskInfo, options: WaitOptions? = nil) async throws -> Task {
    try await withCheckedThrowingContinuation { continuation in
      self.waitForTask(task: task, options: options) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getTask(taskUid:_:)`
   */
  public func getTask(taskUid: Int) async throws -> Task {
    try await withCheckedThrowingContinuation { continuation in
      self.getTask(taskUid: taskUid) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getTasks(params:_:)`
   */
  public func getTasks(params: TasksQuery? = nil) async throws -> TasksResults {
    try await withCheckedThrowingContinuation { continuation in
      self.getTasks(params: params) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `cancelTasks(filter:completion:)`
   */
  public func cancelTasks(filter: CancelTasksQuery) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.cancelTasks(filter: filter) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `deleteTasks(filter:completion:)`
   */
  public func deleteTasks(filter: DeleteTasksQuery) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.deleteTasks(filter: filter) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getKeys(params:_:)`
   */
  public func getKeys(params: KeysQuery? = nil) async throws -> KeysResults {
    try await withCheckedThrowingContinuation { continuation in
      self.getKeys(params: params) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getKey(keyOrUid:_:)`
   */
  public func getKey(keyOrUid: String) async throws -> Key {
    try await withCheckedThrowingContinuation { continuation in
      self.getKey(keyOrUid: keyOrUid) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `createKey(_:_:)`
   */
  public func createKey(_ keyParams: KeyParams) async throws -> Key {
    try await withCheckedThrowingContinuation { continuation in
      self.createKey(keyParams) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateKey(keyOrUid:keyParams:_:)`
   */
  public func updateKey(keyOrUid: String, keyParams: KeyUpdateParams) async throws -> Key {
    try await withCheckedThrowingContinuation { continuation in
      self.updateKey(keyOrUid: keyOrUid, keyParams: keyParams) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `deleteKey(keyOrUid:_:)`
   */
  public func deleteKey(keyOrUid: String) async throws {
    try await withCheckedThrowingContinuation { continuation in
      self.deleteKey(keyOrUid: keyOrUid) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `allStats(_:)`
   */
  public func allStats() async throws -> AllStats {
    try await withCheckedThrowingContinuation { continuation in
      self.allStats { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `health(_:)`
   */
  public func health() async throws -> Health {
    try await withCheckedThrowingContinuation { continuation in
      self.health { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `isHealthy(_:)`
   */
  public func isHealthy() async -> Bool {
    await withCheckedContinuation { continuation in
      self.isHealthy { result in
        continuation.resume(returning: result)
      }
    }
  }

  /**
   See `version(_:)`
   */
  public func version() async throws -> Version {
    try await withCheckedThrowingContinuation { continuation in
      self.version { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `createDump(_:)`
   */
  public func createDump() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.createDump { result in
        continuation.resume(with: result)
      }
    }
  }
}
