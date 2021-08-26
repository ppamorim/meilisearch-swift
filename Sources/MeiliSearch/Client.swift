import Foundation

/**
 A `MeiliSearch` instance represents a MeiliSearch client used to easily integrate
 your Swift product with the MeiliSearch server.

 - warning: `MeiliSearch` instances are thread safe and can be shared across threads
 or dispatch queues.
 */
public struct MeiliSearch {

  // MARK: Properties

  /**
   Current and immutable MeiliSearch configuration. To change this configuration please
   create a new MeiliSearch instance.
   */
  private(set) var config: Config

  private let indexes: Indexes
  private let documents: Documents
  private let search: Search
  private let updates: Updates
  private let keys: Keys
  private let settings: Settings
  private let stats: Stats
  private let system: System
  private let dumps: Dumps

  // MARK: Initializers

  /**
   Create an instance of MeiliSearch client.

   - parameter host:   The host to the MeiliSearch http server.
   - parameter apiKey:    The authorisation key to communicate with MeiliSearch.
   - parameter session:   A custom produced URLSessionProtocol.
   */
  public init(host: String, apiKey: String? = nil, session: URLSessionProtocol? = nil) throws {
    self.config = try Config(host: host, apiKey: apiKey, session: session).validate()
    let request: Request = Request(self.config)
    self.indexes = Indexes(request)
    self.documents = Documents(request)
    self.search = Search(request)
    self.updates = Updates(request)
    self.keys = Keys(request, self.config)
    self.settings = Settings(request)
    self.stats = Stats(request)
    self.system = System(request)
    self.dumps = Dumps(request)
  }

  // MARK: Index

  /**
   Create a new Index for the given `uid`.

   - parameter UID:        The unique identifier for the `Index` to be created.
   - parameter completion: The completion closure used to notify when the server
   completes the write request, it returns a `Result` object that contains `Index`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func createIndex(
    UID: String,
    _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {
    self.indexes.create(UID, completion)
  }

  /**
   Get or create a new Index for the given `uid`.

   - parameter UID:        The unique identifier for the `Index` to be created.
   - parameter completion: The completion closure used to notify when the server
   completes the write request, it returns a `Result` object that contains `Index`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getOrCreateIndex(
    UID: String,
    _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {
    self.indexes.getOrCreate(UID, completion)
  }

  /**
   Get the Index for the given `uid`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Index`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getIndex(
    UID: String,
    _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {
    self.indexes.get(UID, completion)
  }

  /**
   List the all Indexes.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[Index]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getIndexes(
    _ completion: @escaping (Result<[Index], Swift.Error>) -> Void) {
    self.indexes.getAll(completion)
  }

  /**
   Update index name.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter name:       New index name.
   - parameter completion: The completion closure used to notify when the server
   completes the update request, it returns a `Result` object that contains `()`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateIndex(
    UID: String,
    primaryKey: String,
    _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {
    self.indexes.update(UID, primaryKey, completion)
  }

  /**
   Delete the Index for the given `uid`.

   - parameter completion: The completion closure used to notify when the server
   completes the delete request, it returns a `Result` object that contains `()`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func deleteIndex(
    UID: String,
    _ completion: @escaping (Result<(), Swift.Error>) -> Void) {
    self.indexes.delete(UID, completion)
  }

  // MARK: Document

  /**
   Add a list of documents or replace them if they already exist.

   If you send an already existing document (same id) the whole existing document will
   be overwritten by the new document. Fields previously in the document not present in
   the new document are removed.

   For a partial update of the document see `updateDocument`.

   - parameter UID:        The unique identifier for the Document's index to be found.
   - parameter documents:  The documents to be processed.
   - parameter completion: The completion closure used to notify when the server
   completes the update request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func addDocuments<T>(
    UID: String,
    documents: [T],
    encoder: JSONEncoder? = nil,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) where T: Encodable {
    self.documents.add(
      UID,
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

   For a partial update of the document see `updateDocument`.

   - parameter UID:        The unique identifier for the Document's index to be found.
   - parameter documents:  The  data to be processed.
   - parameter completion: The completion closure used to notify when the server
   completes the update request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func addDocuments(
    UID: String,
    documents: Data,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.documents.add(
      UID,
      documents,
      primaryKey,
      completion)
  }

  /**
   Add a list of documents and update them if they already.

   If you send an already existing document (same id) the old document
   will be only  partially updated according to the fields of the new
   document. Thus, any fields not present in the new document are kept
   and remained unchanged.

   To completely overwrite a document see `addDocument`.

   - parameter UID:        The unique identifier for the Document's index to be found.
   - parameter documents:   The document data (JSON) to be processed.
   - parameter completion: The completion closure used to notify when the server
   completes the update request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateDocuments(
    UID: String,
    documents: Data,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.documents.update(
      UID,
      documents,
      primaryKey,
      completion
    )
  }

  /**
   Get the Document for the given `uid` and `identifier`.

   - parameter UID:        The unique identifier for the Document's index to be found.
   - parameter identifier: The document identifier for the Document to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains  `T` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getDocument<T>(
    UID: String,
    identifier: String,
    _ completion: @escaping (Result<T, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    self.documents.get(UID, identifier, completion)
  }

  /**
   Get the Document for the given `uid` and `identifier`.

   - parameter UID:        The unique identifier for the Document's index to be found.
   - parameter identifier: The document identifier for the Document to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains  `T` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getDocument<T>(
    UID: String,
    identifier: Int,
    _ completion: @escaping (Result<T, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    self.documents.get(UID, String(identifier), completion)
  }

  /**
   List the all Documents.

   - parameter UID:        The unique identifier for the Document's index to be found.
   - parameter limit:      Limit the size of the query.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains
   `[T]` value. If the request was sucessful or `Error` if a
   failure occured.
   */
  public func getDocuments<T>(
    UID: String,
    options: GetParameters? = nil,
    _ completion: @escaping (Result<[T], Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    self.documents.getAll(UID, options, completion)
  }

  /**
   Delete the Document for the given `uid` and `identifier`.

   - parameter UID:        The unique identifier for the Document's index to be found.
   - parameter identifier: The document identifier for the Document to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the delete request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func deleteDocument(
    UID: String,
    identifier: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.documents.delete(UID, identifier, completion)
  }

  /**
   Delete all Documents for the given `uid`.

   - parameter UID:        The unique identifier for the Document's index to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the delete request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func deleteAllDocuments(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.documents.deleteAll(UID, completion)
  }

  /**
   Delete a selection of documents based on array of document `uid`'s.

   - parameter UID:          The unique identifier for the Document's index to be deleted.
   - parameter documentsUID: The array of unique identifier for the Document to be deleted.
   - parameter completion:   The completion closure used to notify when the server
   completes the delete request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func deleteBatchDocuments(
    UID: String,
    documentsUID: [Int],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.documents.deleteBatch(UID, documentsUID, completion)
  }

  /**
   Search for a document in the `uid` and `searchParameters`

   - parameter UID:              The unique identifier for the Document's index to
   be found.
   - parameter searchParameters: The document identifier for the Document to be found.
   - parameter completion:       The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains  `SearchResult<T>`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func search<T>(
    UID: String,
    _ searchParameters: SearchParameters,
    _ completion: @escaping (Result<SearchResult<T>, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    self.search.search(UID, searchParameters, completion)
  }

  // MARK: Updates

  /**
   Get the status of an update in a given `Index`.

   - parameter UID:       The unique identifier for the Document's index to
   be found.
   - parameter update:    The update value.
   - parameter completion:The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getUpdate(
    UID: String,
    _ update: Update,
    _ completion: @escaping (Result<Update.Result, Swift.Error>) -> Void) {
    self.updates.get(UID, update, completion)
  }

  /**
   Get the status of an update in a given `Index`.

   - parameter UID:       The unique identifier for the Document's index to
   be found.
   - parameter update:    The update value.
   - parameter completion:The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getAllUpdates(
    UID: String,
    _ completion: @escaping (Result<[Update.Result], Swift.Error>) -> Void) {
    self.updates.getAll(UID, completion)
  }

  // MARK: Keys

  /**
   Each instance of MeiliSearch has three keys: a master, a private, and a public. Each key has a given
   set of permissions on the API routes.

   - parameter masterKey:  Master key to access the `keys` function.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func keys(
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    self.keys.get(completion)
  }

  // MARK: Settings

  /**
   Get a list of all the customization possible for an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Setting`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getSetting(
    UID: String,
    _ completion: @escaping (Result<SettingResult, Swift.Error>) -> Void) {
    self.settings.get(UID, completion)
  }

  /**
   Update the settings for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter setting:    Setting to be applied into `Index`.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateSetting(
    UID: String,
    _ setting: Setting,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.update(UID, setting, completion)
  }

  /**
   Reset the settings for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetSetting(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.reset(UID, completion)
  }

  // MARK: Synonyms

  /**
   Get a list of all synonyms possible for an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String: [String]]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getSynonyms(
    UID: String,
    _ completion: @escaping (Result<[String: [String]], Swift.Error>) -> Void) {
    self.settings.getSynonyms(UID, completion)
  }

  /**
   Update the synonyms for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter setting:    Setting to be applied into `Index`.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateSynonyms(
    UID: String,
    _ synonyms: [String: [String]]?,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateSynonyms(UID, synonyms, completion)
  }

  /**
   Reset the synonyms for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetSynonyms(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetSynonyms(UID, completion)
  }

  // MARK: Stop words

  /**
   Get a list of all stop-words possible for an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getStopWords(
    UID: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getStopWords(UID, completion)
  }

  /**
   Update the stop-words for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter stopWords:  Array of stop-word to be applied into `Index`.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateStopWords(
    UID: String,
    _ stopWords: [String]?,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateStopWords(UID, stopWords, completion)
  }

  /**
   Reset the stop-words for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetStopWords(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetStopWords(UID, completion)
  }

  // MARK: Ranking rules

  /**
   Get a list of all ranking rules possible for an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getRankingRules(
    UID: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getRankingRules(UID, completion)
  }

  /**
   Update the ranking rules for a given `Index`.

   - parameter UID:          The unique identifier for the `Index` to be found.
   - parameter rankingRules: Array of ranking rules to be applied into `Index`.
   - parameter completion:   The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateRankingRules(
    UID: String,
    _ rankingRules: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateRankingRules(UID, rankingRules, completion)
  }

  /**
   Reset the ranking rules for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetRankingRules(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetRankingRules(UID, completion)
  }

  // MARK: Distinct Attribute

  /**
   Get the distinct attribute field of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getDistinctAttribute(
    UID: String,
    _ completion: @escaping (Result<String?, Swift.Error>) -> Void) {
    self.settings.getDistinctAttribute(UID, completion)
  }

  /**
   Update the distinct attribute field of an `Index`.

   - parameter UID:               The unique identifier for the `Index` to be found.
   - parameter distinctAttribute: The distinct attribute to be applied into `Index`.
   - parameter completion:        The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateDistinctAttribute(
    UID: String,
    _ distinctAttribute: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateDistinctAttribute(
      UID,
      distinctAttribute,
      completion)
  }

  /**
   Reset the distinct attribute field of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetDistinctAttribute(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetDistinctAttribute(UID, completion)
  }

  // MARK: Searchable Attribute

  /**
   Get the searchable attribute field of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getSearchableAttributes(
    UID: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getSearchableAttributes(UID, completion)
  }

  /**
   Update the searchable attribute field of an `Index`.

   - parameter UID:                 The unique identifier for the `Index` to be found.
   - parameter searchableAttribute: The searchable attribute to be applied into `Index`.
   - parameter completion:          The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateSearchableAttributes(
    UID: String,
    _ searchableAttribute: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateSearchableAttributes(
      UID,
      searchableAttribute,
      completion)
  }

  /**
   Reset the searchable attribute field of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetSearchableAttributes(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetSearchableAttributes(UID, completion)
  }

  // MARK: Displayed Attribute

  /**
   Get the displayed attribute field of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getDisplayedAttributes(
    UID: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getDisplayedAttributes(UID, completion)
  }

  /**
   Update the displayed attribute field of an `Index`.

   - parameter UID:                The unique identifier for the `Index` to be found.
   - parameter displayedAttribute: The displayed attribute to be applied into `Index`.
   - parameter completion:         The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateDisplayedAttributes(
    UID: String,
    _ displayedAttribute: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateDisplayedAttributes(
      UID,
      displayedAttribute,
      completion)
  }

  /**
   Reset the displayed attribute field of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetDisplayedAttributes(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetDisplayedAttributes(UID, completion)
  }

  // MARK: Filterable attributes

  /**
   Get the attributes selected to be faceted of an `Index`.

   - parameter UID:             The unique identifier for the `Index` to be found.
   - parameter completion:      The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains an `[String]`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func getFilterableAttributes(
    UID: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getFilterableAttributes(UID, completion)
  }

  /**
   Update the faceted attributes of an `Index`.

   - parameter UID:             The unique identifier for the `Index` to be found.
   - parameter attributes:   The faceted attributes to be applied into `Index`.
   - parameter completion:      The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func updateFilterableAttributes(
    UID: String,
    _ attributes: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateFilterableAttributes(UID, attributes, completion)
  }

  /**
   Reset the faceted attributes of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func resetFilterableAttributes(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetFilterableAttributes(UID, completion)
  }

  // MARK: Stats

  /**
   Get stats of an index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Stat` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func stat(
    UID: String,
    _ completion: @escaping (Result<Stat, Swift.Error>) -> Void) {
    self.stats.stat(UID, completion)
  }

  /**
   Get stats of all indexes.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `AllStats`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func allStats(
    _ completion: @escaping (Result<AllStats, Swift.Error>) -> Void) {
    self.stats.allStats(completion)
  }

  // MARK: System

  /**
   Get health of MeiliSearch server.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Health` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func health(_ completion: @escaping (Result<Health, Swift.Error>) -> Void) {
    self.system.health(completion)
  }

  /**
   Get health of MeiliSearch server.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Bool` that is `true`
   If the request was sucessful or `false` if a failure occured.
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
   Get version of MeiliSearch.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Version`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func version(
    _ completion: @escaping (Result<Version, Swift.Error>) -> Void) {
    self.system.version(completion)
  }

  /**
   Triggers a dump creation process. Once the process is complete, a dump is created in the dumps folder.
   If the dumps folder does not exist yet, it will be created.

   - parameter completion: The completion closure used to notify when the server
   completes the dump request, it returns a `Dump` object that contains `UID`
   value that can be used later to check the status of the dump.
   If the request was successful or `Error` if a failure occurred.
   */
  public func createDump(_ completion: @escaping (Result<Dump, Swift.Error>) -> Void) {
    self.dumps.create(completion)
  }

  /**
   Get the status of a dump creation process using the uid returned after calling the dump creation route.
   The returned status could be:

   `Dump.Status.inProgress`: Dump creation is in progress.
   `Dump.Status.failed`: An error occurred during the dump process, and the task was aborted.
   `Dump.Status.done`: Dump creation is finished and was successful.

   - parameter completion: The completion closure used to notify when the server
   completes the dump request, it returns a `Dump` object that contains `UID`
   value that can be used later to check the status of the Dump.
   If the request was successful or `Error` if a failure occurred.
   */
  public func getDumpStatus(
    UID: String,
    _ completion: @escaping (Result<Dump, Swift.Error>) -> Void) {
    self.dumps.status(UID, completion)
  }

}
