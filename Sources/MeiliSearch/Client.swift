import Foundation
import MeiliSearchCore

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 A `MeiliSearch` instance represents a Meilisearch client used to easily integrate
 your Swift product with the Meilisearch server.

 - warning: `Meilisearch` instances are thread safe and can be shared across threads
 or dispatch queues.
 */
public struct MeiliSearch {
  // MARK: Properties

  /**
   Current and immutable Meilisearch configuration. To change this configuration please
   create a new Meilisearch instance.
   */
  private let request: Request
  private(set) var config: Config
  private let keys: Keys
  private let stats: Stats
  private let system: System
  private let dumps: Dumps
  private let tasks: Tasks

  // MARK: Initializers

  /**
   Create an instance of MeiliSearch client.

   - parameter host:   The host to the Meilisearch http server.
   - parameter apiKey:    The authorization key to communicate with Meilisearch.
   - parameter session:   A custom produced `URLSessionProtocol`.
   - parameter headers: A dictionary of custom headers passed with every API request.
   */
  public init(host: String, apiKey: String? = nil, session: URLSessionProtocol? = nil, headers: [String: String] = [:]) throws {
    self.config = try Config(host: host, apiKey: apiKey, session: session, headers: headers).validate()
    self.request = Request(self.config)
    self.keys = Keys(self.request)
    self.stats = Stats(self.request)
    self.system = System(self.request)
    self.dumps = Dumps(self.request)
    self.tasks = Tasks(self.request)
  }

  // MARK: Index
  /**
  Create an instance of `Index`.

  - parameter uid: The unique identifier for the `Index` to be created.
   */
  public func index(_ uid: String) -> Indexes {
    Indexes(config: self.config, uid: uid)
  }

  /**
   Create a new index.

  - parameter uid: The unique identifier for the `Index` to be created.
  - parameter primaryKey: The unique field of a document.
  - parameter completion: The completion closure is used to notify when the server
   completes the write request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func createIndex(
    uid: String,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    Indexes.create(uid: uid, primaryKey: primaryKey, config: self.config, completion)
  }

  /**
   Get an index.

   - parameter uid: The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `Index`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func getIndex(
    _ uid: String,
    _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {
    self.index(uid).get(completion)
  }

  /**
   List indexes given an optional criteria.

   - parameter params: A `IndexesQuery?` object with pagination & filter metadata.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `IndexesResults`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func getIndexes(
    params: IndexesQuery? = nil,
    _ completion: @escaping (Result<IndexesResults, Swift.Error>) -> Void) {
    Indexes.getAll(config: self.config, params: params, completion)
  }

  /**
   Update the `primaryKey` of the index.

  - parameter uid: The unique identifier of the index
  - parameter primaryKey: The unique field of a document.
  - parameter completion: The completion closure is used to notify when the server
   completes the update request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func updateIndex(
    uid: String,
    primaryKey: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.index(uid).update(primaryKey: primaryKey, completion)
  }

  /**
   Delete an index.

  - parameter uid: The unique identifier of the index.
  - parameter completion: The completion closure is used to notify when the server
   completes the delete request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func deleteIndex(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.index(uid).delete(completion)
  }

  public func swapIndexes(
    _ pairs: [(String, String)],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    Indexes.swapIndexes(pairs: pairs, request: request, completion)
  }

  // MARK: Wait for Task

  /**
    Wait for a task to be successful or fail.

    Using a task returned by an asynchronous route of Meilisearch, wait for completion.

    - parameter taskUid: The uid of the task.
    - parameter options: Optional configuration for timeout and interval
    - parameter completion: The completion closure is used to notify when the server
   completes the update request, it returns a `Result` object that contains `Task`
   value. If the request was successful or `Error` if a failure occurred.
  **/
  public func waitForTask(
    taskUid: Int,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void
  ) {
    self.tasks.waitForTask(taskUid: taskUid, options: options, completion)
  }

  /**
    Wait for a task to be succeeded or failed.

    Using a task returned by an asynchronous route of Meilisearch, wait for completion.

    - parameter task: The task.
    - parameter options: Optionnal configuration for timeout and interval
    - parameter completion: The completion closure is used to notify when the server
  **/

  public func waitForTask(
    task: TaskInfo,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void
  ) {
    self.tasks.waitForTask(taskUid: task.taskUid, options: options, completion)
  }

  // MARK: Tasks

 /**
   Get the information of a task.

   - parameter taskUid:    The task unique identifier.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `Task` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func getTask(
    taskUid: Int,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
    self.tasks.get(taskUid: taskUid, completion)
  }

  /**
   List tasks based on an optional pagination criteria

   - parameter params: A `TasksQuery?` object with pagination metadata.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TasksResults` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func getTasks(
    params: TasksQuery? = nil,
    _ completion: @escaping (Result<TasksResults, Swift.Error>) -> Void) {
    self.tasks.getTasks(params: params, completion)
  }

  /**
   Cancel any number of enqueued or processing tasks, stopping them from continuing to run

   - parameter filter: The filter in which chooses which tasks will be canceled
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func cancelTasks(
    filter: CancelTasksQuery,
    completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.tasks.cancelTasks(filter, completion)
  }

  /**
   Delete a finished (succeeded, failed, or canceled) task

   - parameter filter: The filter in which chooses which tasks will be deleted
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func deleteTasks(
    filter: DeleteTasksQuery,
    completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.tasks.deleteTasks(filter, completion)
  }

  // MARK: Keys

  /**
   List keys based on an optional pagination criteria

   - parameter params: A `KeysQuery?` object with pagination metadata.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `KeysResults` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func getKeys(
    params: KeysQuery? = nil,
    _ completion: @escaping (Result<KeysResults, Swift.Error>) -> Void) {
      self.keys.getAll(params: params, completion)
  }

  /**
   Get one key's information using the key value.

   - parameter keyOrUid: Key identifier, can be uid or key.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func getKey(
    keyOrUid: String,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    self.keys.get(key: keyOrUid, completion)
  }

  /**
    Create an API key.

   - parameter keyParams: Parameters object required to create a key.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func createKey(
    _ keyParams: KeyParams,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    self.keys.create(keyParams, completion)
  }

  /**
    Update an API key.

   - parameter keyOrUid: Key identifier, can be uid or key.
   - parameter keyParams: `KeyUpdateParams` object required to update a key.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func updateKey(
    keyOrUid: String,
    keyParams: KeyUpdateParams,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    self.keys.update(
      keyOrUid: keyOrUid,
      keyParams: keyParams,
      completion
    )
  }

  /**
    Delete an API key.

   - parameter keyOrUid: Key identifier, can be uid or key.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `()` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func deleteKey(
    keyOrUid: String,
    _ completion: @escaping (Result<(), Swift.Error>) -> Void) {
    self.keys.delete(
      keyOrUid: keyOrUid,
      completion
    )
  }

  // MARK: Stats

  /**
   Get stats of all indexes.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `AllStats`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func allStats(
    _ completion: @escaping (Result<AllStats, Swift.Error>) -> Void) {
    self.stats.allStats(completion)
  }

  // MARK: System

  /**
   Get health of Meilisearch server.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `Health` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func health(_ completion: @escaping (Result<Health, Swift.Error>) -> Void) {
    self.system.health(completion)
  }

  /**
   Returns whether Meilisearch server is healthy or not.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Bool` that is `true`
   If the request was successful or `false` if a failure occured.
   */
  public func isHealthy(_ completion: @escaping (Bool) -> Void) {
    self.health { result in
      switch result {
      case .success:
        completion(true)
      case .failure:
        completion(false)
      }
    }
  }

  /**
   Get version of Meilisearch.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `Version`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func version(
    _ completion: @escaping (Result<Version, Swift.Error>) -> Void) {
    self.system.version(completion)
  }

  /**
   Triggers a dump creation process. Once the process is complete, a dump is created in the dumps folder.
   If the dumps folder does not exist yet, it will be created.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func createDump(_ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.dumps.create(completion)
  }
}

extension TaskInfo {
  @discardableResult
  @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
  public func wait(on client: MeiliSearch, options: WaitOptions? = nil) async throws -> Task {
    try await client.waitForTask(task: self, options: options)
  }
}
