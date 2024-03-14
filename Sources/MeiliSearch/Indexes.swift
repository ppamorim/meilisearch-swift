import Foundation
import MeiliSearchCore

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct Indexes {
  // MARK: Properties

  let request: Request

  let config: Config

  /// The index uid.
  public let uid: String

  /// The data when the index was created.
  public let createdAt: Date?

  /// The data when the index was last updated.
  public let updatedAt: Date?

  /// The primary key configured for the index.
  public let primaryKey: String?

  // Document methods
  private let documents: Documents

  // Search methods
  private let search: Search

  // Settings methods
  private let settings: Settings

  // Stats methods
  private let stats: Stats

  // Tasks methods
  private let tasks: Tasks

  // MARK: Initializers

  init (
    config: Config,
    uid: String,
    primaryKey: String? = nil,
    createdAt: Date? = nil,
    updatedAt: Date? = nil,
    request: Request? = nil
    ) {
    self.config = config
    if let request: Request = request {
      self.request = request
    } else {
      self.request = Request(self.config)
    }
    self.uid = uid
    self.primaryKey = primaryKey
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.documents = Documents(Request(config))
    self.search = Search(Request(config))
    self.tasks = Tasks(Request(config))
    self.settings = Settings(Request(config))
    self.stats = Stats(Request(config))
  }

  // MARK: Functions

  /**
   Get the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request. It returns a `Result` object that contains `Index`
   value if the request was successful or `Error` if a failure occurred.
   */
  public func get(_ completion: @escaping (Result<Index, Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(self.uid)") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let index: Index = try Constants.customJSONDecoder.decode(
            Index.self,
            from: data)
          completion(.success(index))
        } catch {
          dump(error)
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  /**
   List indexes given an optional criteria.

   - parameter params: A `IndexesQuery?` object with pagination & filter metadata.
   - parameter config: Optional `Request` configuration.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `IndexesResults`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public static func getAll(config: Config, params: IndexesQuery? = nil, _ completion: @escaping (Result<IndexesResults, Swift.Error>) -> Void) {
    Request(config).get(api: "/indexes", param: params?.toQuery()) { result in
      switch result {
      case .success(let result):
        guard let result: Data = result else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let indexes = try Constants.customJSONDecoder.decode(IndexesResults.self, from: result)

          completion(.success(indexes))
        } catch let error {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  /**
   Create a new Index for the given `uid`.

   - parameter uid: The unique identifier for the `Index` to be created.
   - parameter primaryKey: The unique field of a document.
   - parameter completion: The completion closure is used to notify when the server
   completes the write request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public static func create(
    uid: String,
    primaryKey: String? = nil,
    config: Config,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    let payload = CreateIndexPayload(uid: uid, primaryKey: primaryKey)
    let data: Data
    do {
      data = try JSONEncoder().encode(payload)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    Request(config).post(api: "/indexes", data) { result in
      switch result {
      case .success(let data):
      do {
        let result: TaskInfo = try Constants.customJSONDecoder.decode(
          TaskInfo.self,
          from: data)
          completion(.success(result))
      } catch {
        completion(.failure(error))
      }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  static func swapIndexes(
    pairs: [(old: String, new: String)],
    request: Request,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    let swapIndexPayload: [SwapIndexPayload] = pairs.map {
      SwapIndexPayload(indexes: [ $0.old, $0.new ])
    }

    let data: Data
    do {
      data = try JSONEncoder().encode(swapIndexPayload)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    request.post(api: "/swap-indexes", data) { result in
      switch result {
      case .success(let data):
        do {
          let taskInfo: TaskInfo = try Constants.customJSONDecoder.decode(
            TaskInfo.self,
            from: data)
          completion(.success(taskInfo))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  /**
   Update the index primaryKey.

  - parameter primaryKey: the unique field of a document.
  - parameter completion: The completion closure is used to notify when the server
   completes the update request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func update(
    primaryKey: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    let payload = UpdateIndexPayload(primaryKey: primaryKey)
    let data: Data
    do {
      data = try JSONEncoder().encode(payload)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    self.request.patch(api: "/indexes/\(self.uid)", data) { result in
      switch result {
      case .success(let data):
        do {
          let task: TaskInfo = try Constants.customJSONDecoder.decode(
            TaskInfo.self,
            from: data)
            completion(.success(task))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  /**
   Delete the index.

  - parameter completion: The completion closure is used to notify when the server
   completes the delete request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func delete(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.request.delete(api: "/indexes/\(self.uid)") { result in
      switch result {
      case .success(let data):
        guard let data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let task: TaskInfo = try Constants.customJSONDecoder.decode(
            TaskInfo.self,
            from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // MARK: Document

  /**
   Add a list of documents or replace them if they already exist.

   If you send an already existing document (same id) the whole existing document will
   be overwritten by the new document. Fields previously in the document not present in
   the new document are removed.

   For a partial update of the document see `updateDocuments`.

   - parameter documents:  The documents to add in Meilisearch.
   - parameter encoder:    The data structure of your documents.
   - parameter primaryKey: The primary key of a document.
   - parameter completion: The completion closure is used to notify when the server
   completes the update request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func addDocuments<T>(
    documents: [T],
    encoder: JSONEncoder? = nil,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) where T: Encodable {
    self.documents.add(
      self.uid,
      documents,
      encoder,
      primaryKey,
      completion)
  }

  /**
   Add a list of documents as data or replace them if they already exist.

   If you send an already existing document (same id) the whole existing document will
   be overwritten by the new document. Fields previously in the document not present in
   the new document are removed.

   For a partial update of the document see `updateDocuments`.

   - parameter documents:  The document data (JSON) to be processed.
   - parameter primaryKey: The primary key of a document.
   - parameter completion: The completion closure is used to notify when the server
   completes the update request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func addDocuments(
    documents: Data,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.documents.add(
      self.uid,
      documents,
      primaryKey,
      completion)
  }

  /**
    Add a list of documents or update them if they already exist. If the provided index does not exist, it will be created.

    If you send an already existing document (same documentId) the old document will be only partially
    updated according to the fields of the new document.
    Thus, any fields not present in the new document are kept and remained unchanged.

    To completely overwrite a document, `addDocuments`

   - parameter documents:  The documents to update in Meilisearch.
   - parameter encoder:    The data structure of your documents.
   - parameter primaryKey: The primary key of a document.
   - parameter completion: The completion closure is used to notify when the server
   completes the update request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func updateDocuments<T>(
    documents: [T],
    encoder: JSONEncoder? = nil,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) where T: Encodable {
    self.documents.update(
      self.uid,
      documents,
      encoder,
      primaryKey,
      completion)
  }

  /**
    Add a list of documents or update them if they already exist. If the provided index does not exist, it will be created.

    If you send an already existing document (same documentId) the old document will be only partially
    updated according to the fields of the new document.
    Thus, any fields not present in the new document are kept and remained unchanged.

    To completely overwrite a document, `addDocuments`

   - parameter documents: The document data (JSON) to be processed.
   - parameter primaryKey: The primary key of a document.
   - parameter completion: The completion closure is used to notify when the server
   completes the update request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func updateDocuments(
    documents: Data,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.documents.update(
      self.uid,
      documents,
      primaryKey,
      completion
    )
  }

  /**
   Get the document on the index based on the provided document identifier.

   - parameter identifier: The document identifier for the document to be found.
   - parameter fields: List of fields that should be returned in the response. Be careful with this option, since `T` should be able to handle the missing fields.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains  `T` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func getDocument<T>(
    _ identifier: String,
    fields: [String]? = nil,
    _ completion: @escaping (Result<T, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    self.documents.get(self.uid, identifier, fields: fields, completion)
  }

  /**
   Get the document on the index based on the provided document identifier.

   - parameter identifier: The document identifier for the document to be found.
   - parameter fields: List of fields that should be returned in the response. Be careful with this option, since `T` should be able to handle the missing fields.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains  `T` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func getDocument<T>(
    _ identifier: Int,
    fields: [String]? = nil,
    _ completion: @escaping (Result<T, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    self.documents.get(self.uid, String(identifier), fields: fields, completion)
  }

  /**
   List documents given an optional criteria.

   - parameter params: A `DocumentsQuery?` object with pagination & filter metadata.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `DocumentsResults<T>` value.
   If the request was successful or `Error` if a failure occured.
   */
  public func getDocuments<T>(
    params: DocumentsQuery? = nil,
    _ completion: @escaping (Result<DocumentsResults<T>, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    self.documents.getAll(self.uid, params: params, completion)
  }

  /**
   Delete a document on the index based on the provided document identifier.

   - parameter documentId: The document identifier of the document.
   - parameter completion: The completion closure is used to notify when the server
   completes the delete request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func deleteDocument(
    _ documentId: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.documents.delete(self.uid, documentId, completion)
  }

  /**
   Delete all documents on the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the delete request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func deleteAllDocuments(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.documents.deleteAll(self.uid, completion)
  }

  /**
   Delete a selection of documents based on array of document `identifiers`'s.

   - parameter documentIds: The array of unique identifier for the document to be deleted.
   - parameter completion: The completion closure is used to notify when the server
   completes the delete request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func deleteBatchDocuments(
    _ documentIds: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.documents.deleteBatch(self.uid, documentIds, completion)
  }

  /**
   Delete a selection of documents based on array of document `identifiers`'s.

   - parameter documentIds: The array of unique identifier for the document to be deleted.
   - parameter completion: The completion closure is used to notify when the server
   completes the delete request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  @available(*, deprecated, message: "Please use string values for `documentIds` instead of integers.")
  public func deleteBatchDocuments(
    _ documentIds: [Int],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    let documentIdStrings = documentIds.map { String($0) }
    self.documents.deleteBatch(self.uid, documentIdStrings, completion)
  }

  // MARK: Search

  /**
   Search in the index.

   - parameter searchParameters: Options on search.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains  `SearchResult<T>`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func search<T>(
    _ searchParameters: SearchParameters,
    _ completion: @escaping (Result<Searchable<T>, Swift.Error>) -> Void)
  where T: Decodable {
    self.search.search(self.uid, searchParameters, completion)
  }

  // MARK: Tasks

  /**
   Get a task.

   - parameter taskuid: The task identifier.
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
   Get tasks from a given index based on optional criteria.

   - parameter params: A `TasksQuery?` object with pagination & filter metadata.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TasksResults` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func getTasks(
    params: TasksQuery? = nil,
    _ completion: @escaping (Result<TasksResults, Swift.Error>) -> Void) {
    self.tasks.getTasks(uid: self.uid, params: params, completion)
  }

  // MARK: Settings

  /**
   Get a list of all the customization possible of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `Setting`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func getSettings(
    _ completion: @escaping (Result<SettingResult, Swift.Error>) -> Void) {
    self.settings.get(self.uid, completion)
  }

  /**
   Update the settings of the index.

   - parameter setting: Settings to change.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func updateSettings(
    _ setting: Setting,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.update(self.uid, setting, completion)
  }

  /**
   Reset the settings of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func resetSettings(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.reset(self.uid, completion)
  }

  // MARK: Synonyms

  /**
   Get a list of all synonyms possible of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String: [String]]`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func getSynonyms(
    _ completion: @escaping (Result<[String: [String]], Swift.Error>) -> Void) {
    self.settings.getSynonyms(self.uid, completion)
  }

  /**
   Update the synonyms of the index.

   - parameter setting:    Settings to be applied into `Index`.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func updateSynonyms(
    _ synonyms: [String: [String]]?,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updateSynonyms(self.uid, synonyms, completion)
  }

  /**
   Reset the synonyms of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func resetSynonyms(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetSynonyms(self.uid, completion)
  }

  // MARK: Stop words

  /**
   Get a list of all stop-words possible of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func getStopWords(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getStopWords(self.uid, completion)
  }

  /**
   Update the stop-words of the index.

   - parameter stopWords:  Array of stop-word to be applied into `Index`.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func updateStopWords(
    _ stopWords: [String]?,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updateStopWords(self.uid, stopWords, completion)
  }

  /**
   Reset the stop-words of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func resetStopWords(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetStopWords(self.uid, completion)
  }

  // MARK: Ranking rules

  /**
   Get a list of all ranking rules possible of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func getRankingRules(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getRankingRules(self.uid, completion)
  }

  /**
   Update the ranking rules of the index.

   - parameter rankingRules: Array of ranking rules to be applied into `Index`.
   - parameter completion:   The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func updateRankingRules(
    _ rankingRules: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updateRankingRules(self.uid, rankingRules, completion)
  }

  /**
   Reset the ranking rules of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func resetRankingRules(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetRankingRules(self.uid, completion)
  }

  // MARK: Distinct Attribute

  /**
   Get the distinct attribute field of an `Index`.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `String?`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func getDistinctAttribute(
    _ completion: @escaping (Result<String?, Swift.Error>) -> Void) {
    self.settings.getDistinctAttribute(self.uid, completion)
  }

  /**
   Update the distinct attribute field of the index.

   - parameter distinctAttribute: The distinct attribute to be applied into `Index`.
   - parameter completion:        The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func updateDistinctAttribute(
    _ distinctAttribute: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updateDistinctAttribute(
      self.uid,
      distinctAttribute,
      completion)
  }

  /**
   Reset the distinct attribute field of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func resetDistinctAttribute(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetDistinctAttribute(self.uid, completion)
  }

  // MARK: Searchable Attributes

  /**
   Get the searchable attribute field of an `Index`.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func getSearchableAttributes(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getSearchableAttributes(self.uid, completion)
  }

  /**
   Update the searchable attribute field of the index.

   - parameter searchableAttribute: The searchable attribute to be applied into `Index`.
   - parameter completion:          The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func updateSearchableAttributes(
    _ searchableAttribute: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updateSearchableAttributes(
      self.uid,
      searchableAttribute,
      completion)
  }

  /**
   Reset the searchable attribute field of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func resetSearchableAttributes(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetSearchableAttributes(self.uid, completion)
  }

  // MARK: Displayed Attributes

  /**
   Get the displayed attribute field of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func getDisplayedAttributes(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getDisplayedAttributes(self.uid, completion)
  }

  /**
   Update the displayed attribute field of the index.

   - parameter displayedAttribute: The displayed attribute to be applied into `Index`.
   - parameter completion:         The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func updateDisplayedAttributes(
    _ displayedAttribute: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updateDisplayedAttributes(
      self.uid,
      displayedAttribute,
      completion)
  }

  /**
   Reset the displayed attribute field of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value. If the request was successful or `Error` if a failure occurred.
   */
  public func resetDisplayedAttributes(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetDisplayedAttributes(self.uid, completion)
  }

  // MARK: Filterable attributes

  /**
   Get the attributes that are filterable of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains an `[String]`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func getFilterableAttributes(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getFilterableAttributes(self.uid, completion)
  }

  /**
   Update the attributes that are filterable of the index.

   - parameter attributes: The attributes that are filterable on an `Index`.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func updateFilterableAttributes(
    _ attributes: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updateFilterableAttributes(self.uid, attributes, completion)
  }

  /**
   Reset the attributes that are filterable of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func resetFilterableAttributes(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetFilterableAttributes(self.uid, completion)
  }

  // MARK: Sortable attributes

  /**
   Get the attributes that are sortable of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains an `[String]`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func getSortableAttributes(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getSortableAttributes(self.uid, completion)
  }

  /**
   Update the attributes that are sortable of the index.

   - parameter attributes: The attributes that are sortable on an `Index`.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func updateSortableAttributes(
    _ attributes: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updateSortableAttributes(self.uid, attributes, completion)
  }

  /**
   Reset the attributes that are sortable of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func resetSortableAttributes(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetSortableAttributes(self.uid, completion)
  }

  // MARK: Separator Tokens

  /**
   Fetch the `separatorTokens` setting of a Meilisearch index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains an `[String]`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func getSeparatorTokens(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getSeparatorTokens(self.uid, completion)
  }

  /**
   Modify the `separatorTokens` setting of a Meilisearch index.

   - parameter attributes: List of tokens that will be considered as word separators
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func updateSeparatorTokens(
    _ attributes: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updateSeparatorTokens(self.uid, attributes, completion)
  }

  /**
   Reset the `separatorTokens` setting of a Meilisearch index to the default value `[]`.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func resetSeparatorTokens(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetSeparatorTokens(self.uid, completion)
  }

  // MARK: Non Separator Tokens

  /**
   Fetch the `nonSeparatorTokens` setting of a Meilisearch index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains an `[String]`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func getNonSeparatorTokens(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getNonSeparatorTokens(self.uid, completion)
  }

  /**
   Modify the `nonSeparatorTokens` setting of a Meilisearch index.

   - parameter attributes: List of tokens that will not be considered as word separators
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func updateNonSeparatorTokens(
    _ attributes: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updateNonSeparatorTokens(self.uid, attributes, completion)
  }

  /**
   Reset the `nonSeparatorTokens` setting of a Meilisearch index to the default value `[]`.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func resetNonSeparatorTokens(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetNonSeparatorTokens(self.uid, completion)
  }

  // MARK: Dictionary

  /**
   Fetch the `dictionary` setting of a Meilisearch index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains an `[String]`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func getDictionary(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getDictionary(self.uid, completion)
  }

  /**
   Modify the `dictionary` setting of a Meilisearch index.

   - parameter attributes: List of words on which the segmentation will be overridden
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func updateDictionary(
    _ attributes: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updateDictionary(self.uid, attributes, completion)
  }

  /**
   Reset the `dictionary` setting of a Meilisearch index to the default value `[]`.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func resetDictionary(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetDictionary(self.uid, completion)
  }

  // MARK: Pagination

  /**
   Get the pagination settings for the current index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains an `Pagination`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func getPaginationSettings(
    _ completion: @escaping (Result<Pagination, Swift.Error>) -> Void) {
    self.settings.getPaginationSettings(self.uid, completion)
  }

  /**
   Updates the pagination setting for the index.

   - parameter settings: The new preferences to use for pagination.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func updatePaginationSettings(
    _ settings: Pagination,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updatePaginationSettings(self.uid, settings, completion)
  }

  /**
   Reset the pagination settings for the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func resetPaginationSettings(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetPaginationSettings(self.uid, completion)
  }

  // MARK: Typo Tolerance

  /**
   Get the typo tolerance settings.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains a `TypoToleranceResult`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func getTypoTolerance(
    _ completion: @escaping (Result<TypoToleranceResult, Swift.Error>) -> Void) {
    self.settings.getTypoTolerance(self.uid, completion)
  }

  /**
   Update the typo tolerance settings.

   - parameter typoTolerance: An object containing the settings for the `Index`.
   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func updateTypoTolerance(
    _ typoTolerance: TypoTolerance,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.updateTypoTolerance(self.uid, typoTolerance, completion)
  }

  /**
   Reset the typo tolerance settings.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `TaskInfo`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func resetTypoTolerance(
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.settings.resetTypoTolerance(self.uid, completion)
  }

  // MARK: Stats

  /**
   Get stats of the index.

   - parameter completion: The completion closure is used to notify when the server
   completes the query request, it returns a `Result` object that contains `Stat` value.
   If the request was successful or `Error` if a failure occurred.
   */
  public func stats(
    _ completion: @escaping (Result<Stat, Swift.Error>) -> Void) {
    self.stats.stats(self.uid, completion)
  }
}
