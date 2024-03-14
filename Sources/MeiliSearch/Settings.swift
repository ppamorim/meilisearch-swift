import Foundation
import MeiliSearchCore

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 Settings is a list of all the customization possible for an index.
 */
struct Settings {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  // MARK: All Settings

  func get(
    _ uid: String,
    _ completion: @escaping (Result<SettingResult, Swift.Error>) -> Void) {

    getSetting(uid: uid, key: nil, completion: completion)
  }

  func update(
    _ uid: String,
    _ setting: Setting,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    let data: Data
    do {
      data = try JSONEncoder().encode(setting)
    } catch {
      completion(.failure(error))
      return
    }

    // this uses patch instead of put for networking, so shouldn't use the reusable 'updateSetting' function
    self.request.patch(api: "/indexes/\(uid)/settings", data) { result in
      switch result {
      case .success(let data):
        do {
          let task: TaskInfo = try Constants.customJSONDecoder.decode(TaskInfo.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // can this be refactor
  func reset(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: nil, completion: completion)
  }

  // MARK: Synonyms

  func getSynonyms(
    _ uid: String,
    _ completion: @escaping (Result<[String: [String]], Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "synonyms", completion: completion)
  }

  func updateSynonyms(
    _ uid: String,
    _ synonyms: [String: [String]]? = [:],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    updateSetting(uid: uid, key: "synonyms", data: synonyms, completion: completion)
  }

  func resetSynonyms(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "synonyms", completion: completion)
  }

  // MARK: Stop Words

  func getStopWords(
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "stop-words", completion: completion)
  }

  func updateStopWords(
    _ uid: String,
    _ stopWords: [String]? = [],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    updateSetting(uid: uid, key: "stop-words", data: stopWords, completion: completion)
  }

  func resetStopWords(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "stop-words", completion: completion)
  }

  // MARK: Ranking

  func getRankingRules(
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "ranking-rules", completion: completion)
  }

  func updateRankingRules(
    _ uid: String,
    _ rankingRules: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    updateSetting(uid: uid, key: "ranking-rules", data: rankingRules, completion: completion)
  }

  func resetRankingRules(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "ranking-rules", completion: completion)
  }

  // MARK: Distinct attribute

  func getDistinctAttribute(
    _ uid: String,
    _ completion: @escaping (Result<String?, Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "distinct-attribute", completion: completion)
  }

  func updateDistinctAttribute(
    _ uid: String,
    _ distinctAttribute: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    updateSetting(uid: uid, key: "distinct-attribute", data: distinctAttribute, completion: completion)
  }

  func resetDistinctAttribute(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "distinct-attribute", completion: completion)
  }

  // MARK: Searchable attributes

  func getSearchableAttributes(
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "searchable-attributes", completion: completion)
  }

  func updateSearchableAttributes(
    _ uid: String,
    _ searchableAttributes: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    updateSetting(uid: uid, key: "searchable-attributes", data: searchableAttributes, completion: completion)
  }

  func resetSearchableAttributes(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "searchable-attributes", completion: completion)
  }

  // MARK: Displayed attributes

  func getDisplayedAttributes(
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "displayed-attributes", completion: completion)
  }

  func updateDisplayedAttributes(
    _ uid: String,
    _ displayedAttributes: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    updateSetting(uid: uid, key: "displayed-attributes", data: displayedAttributes, completion: completion)
  }

  func resetDisplayedAttributes(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "displayed-attributes", completion: completion)
  }

  // MARK: Filterable Attributes

  func getFilterableAttributes(
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "filterable-attributes", completion: completion)
  }

  func updateFilterableAttributes(
    _ uid: String,
    _ attributes: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    updateSetting(uid: uid, key: "filterable-attributes", data: attributes, completion: completion)
  }

  func resetFilterableAttributes(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "filterable-attributes", completion: completion)
  }

  // MARK: Sortable Attributes

  func getSortableAttributes(
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "sortable-attributes", completion: completion)
  }

  func updateSortableAttributes(
    _ uid: String,
    _ attributes: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    updateSetting(uid: uid, key: "sortable-attributes", data: attributes, completion: completion)
  }

  func resetSortableAttributes(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "sortable-attributes", completion: completion)
  }

  // MARK: Separator Tokens

  func getSeparatorTokens(
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "separator-tokens", completion: completion)
  }

  func updateSeparatorTokens(
    _ uid: String,
    _ attributes: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    updateSetting(uid: uid, key: "separator-tokens", data: attributes, completion: completion)
  }

  func resetSeparatorTokens(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "separator-tokens", completion: completion)
  }

  // MARK: Non-Separator Tokens

  func getNonSeparatorTokens(
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "non-separator-tokens", completion: completion)
  }

  func updateNonSeparatorTokens(
    _ uid: String,
    _ attributes: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    updateSetting(uid: uid, key: "non-separator-tokens", data: attributes, completion: completion)
  }

  func resetNonSeparatorTokens(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "non-separator-tokens", completion: completion)
  }

  // MARK: Dictionary

  func getDictionary(
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "dictionary", completion: completion)
  }

  func updateDictionary(
    _ uid: String,
    _ attributes: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    updateSetting(uid: uid, key: "dictionary", data: attributes, completion: completion)
  }

  func resetDictionary(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "dictionary", completion: completion)
  }

  // MARK: Pagination Preferences

  func getPaginationSettings(
    _ uid: String,
    _ completion: @escaping (Result<Pagination, Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "pagination", completion: completion)
  }

  func updatePaginationSettings(
    _ uid: String,
    _ pagination: Pagination,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    let data: Data
    do {
      data = try JSONEncoder().encode(pagination)
    } catch {
      completion(.failure(error))
      return
    }

    // this uses patch instead of put for networking, so shouldn't use the reusable 'updateSetting' function
    self.request.patch(api: "/indexes/\(uid)/settings/pagination", data) { result in
      switch result {
      case .success(let data):
        do {
          let task: TaskInfo = try Constants.customJSONDecoder.decode(TaskInfo.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func resetPaginationSettings(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "pagination", completion: completion)
  }

  // MARK: Typo Tolerance

  func getTypoTolerance(
    _ uid: String,
    _ completion: @escaping (Result<TypoToleranceResult, Swift.Error>) -> Void) {

    getSetting(uid: uid, key: "typo-tolerance", completion: completion)
  }

  func updateTypoTolerance(
    _ uid: String,
    _ setting: TypoTolerance,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    let data: Data
    do {
      data = try JSONEncoder().encode(setting)
    } catch {
      completion(.failure(error))
      return
    }

    // this uses patch instead of put for networking, so shouldn't use the reusable 'updateSetting' function
    self.request.patch(api: "/indexes/\(uid)/settings/typo-tolerance", data) { result in
      switch result {
      case .success(let data):
        do {
          let task: TaskInfo = try Constants.customJSONDecoder.decode(TaskInfo.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func resetTypoTolerance(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    resetSetting(uid: uid, key: "typo-tolerance", completion: completion)
  }

  // MARK: Reusable Requests

  private func getSetting<ResponseType: Decodable>(
    uid: String,
    key: String?,
    completion: @escaping (Result<ResponseType, Swift.Error>) -> Void
  ) {
    // if a key is provided, path is equal to `/<key>`, else it's an empty string
    let path = key.map { "/" + $0 } ?? ""
    self.request.get(api: "/indexes/\(uid)/settings\(path)") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let array: ResponseType = try Constants.customJSONDecoder.decode(ResponseType.self, from: data)
          completion(.success(array))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  private func updateSetting<T: Encodable>(
    uid: String,
    key: String?,
    data: T,
    completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void
  ) {
    let body: Data
    do {
      body = try JSONEncoder().encode(data)
    } catch {
      completion(.failure(error))
      return
    }

    // if a key is provided, path is equal to `/<key>`, else it's an empty string
    let path = key.map { "/" + $0 } ?? ""
    self.request.put(api: "/indexes/\(uid)/settings\(path)", body) { result in
      switch result {
      case .success(let data):
        do {
          let task: TaskInfo = try Constants.customJSONDecoder.decode(TaskInfo.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  private func resetSetting(
    uid: String,
    key: String?,
    completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void
  ) {
    // if a key is provided, path is equal to `/<key>`, else it's an empty string
    let path = key.map { "/" + $0 } ?? ""
    self.request.delete(api: "/indexes/\(uid)/settings\(path)") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let task: TaskInfo = try Constants.customJSONDecoder.decode(TaskInfo.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
