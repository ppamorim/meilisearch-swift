import Foundation
import MeiliSearchCore

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Indexes {
  /**
   See `get(_:)`
   */
  public func get() async throws -> Index {
    try await withCheckedThrowingContinuation { continuation in
      self.get { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `update(primaryKey:_:)`
   */
  public func update(primaryKey: String) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.update(primaryKey: primaryKey) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `delete(_:)`
   */
  public func delete() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.delete { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `addDocuments(documents:encoder:primaryKey:_:)`
   */
  public func addDocuments<T: Encodable>(documents: [T], encoder: JSONEncoder? = nil, primaryKey: String? = nil) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.addDocuments(documents: documents, encoder: encoder, primaryKey: primaryKey) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `addDocuments(documents:primaryKey:_:)`
   */
  public func addDocuments(documents: Data, primaryKey: String? = nil) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.addDocuments(documents: documents, primaryKey: primaryKey) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateDocuments(documents:encoder:primaryKey:_:)`
   */
  public func updateDocuments<T: Encodable>(documents: [T], encoder: JSONEncoder? = nil, primaryKey: String? = nil) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateDocuments(documents: documents, encoder: encoder, primaryKey: primaryKey) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateDocuments(documents:primaryKey:_:)`
   */
  public func updateDocuments(documents: Data, primaryKey: String? = nil) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateDocuments(documents: documents, primaryKey: primaryKey) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getDocument(_:fields:_:)`
   */
  public func getDocument<T: Codable & Equatable>(_ identifier: String, fields: [String]? = nil) async throws -> T {
    try await withCheckedThrowingContinuation { continuation in
      self.getDocument(identifier, fields: fields) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getDocument(_:fields:_:)`
   */
  public func getDocument<T: Codable & Equatable>(_ identifier: Int, fields: [String]? = nil) async throws -> T {
    try await withCheckedThrowingContinuation { continuation in
      self.getDocument(identifier, fields: fields) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getDocuments(params:_:)`
   */
  public func getDocuments<T: Codable & Equatable>(params: DocumentsQuery? = nil) async throws -> DocumentsResults<T> {
    try await withCheckedThrowingContinuation { continuation in
      self.getDocuments(params: params) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `deleteDocument(_:_:)`
   */
  public func deleteDocument(_ documentId: String) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.deleteDocument(documentId) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `deleteAllDocuments(_:)`
   */
  public func deleteAllDocuments() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.deleteAllDocuments { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `deleteBatchDocuments(_:_:)`
   */
  public func deleteBatchDocuments(_ documentIds: [String]) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.deleteBatchDocuments(documentIds) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `search(_:_:)`
   */
  public func search<T: Decodable>(_ searchParameters: SearchParameters) async throws -> Searchable<T> {
    try await withCheckedThrowingContinuation { continuation in
      self.search(searchParameters) { result in
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
   See `getSettings(_:)`
   */
  public func getSettings() async throws -> SettingResult {
    try await withCheckedThrowingContinuation { continuation in
      self.getSettings { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateSettings(_:_:)`
   */
  public func updateSettings(_ setting: Setting) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateSettings(setting) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetSettings(_:)`
   */
  public func resetSettings() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetSettings { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getSynonyms(_:)`
   */
  public func getSynonyms() async throws -> [String: [String]] {
    try await withCheckedThrowingContinuation { continuation in
      self.getSynonyms { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateSynonyms(_:_:)`
   */
  public func updateSynonyms(_ synonyms: [String: [String]]?) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateSynonyms(synonyms) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetSynonyms(_:)`
   */
  public func resetSynonyms() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetSynonyms { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getStopWords(_:)`
   */
  public func getStopWords() async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      self.getStopWords { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateStopWords(_:_:)`
   */
  public func updateStopWords(_ stopWords: [String]?) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateStopWords(stopWords) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetStopWords(_:)`
   */
  public func resetStopWords() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetStopWords { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getRankingRules(_:)`
   */
  public func getRankingRules() async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      self.getRankingRules { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateRankingRules(_:_:)`
   */
  public func updateRankingRules(_ rankingRules: [String]) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateRankingRules(rankingRules) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetRankingRules(_:)`
   */
  public func resetRankingRules() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetRankingRules { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getDistinctAttribute(_:)`
   */
  public func getDistinctAttribute() async throws -> String? {
    try await withCheckedThrowingContinuation { continuation in
      self.getDistinctAttribute { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateDistinctAttribute(_:_:)`
   */
  public func updateDistinctAttribute(_ distinctAttribute: String) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateDistinctAttribute(distinctAttribute) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetDistinctAttribute(_:)`
   */
  public func resetDistinctAttribute() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetDistinctAttribute { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getSearchableAttributes(_:)`
   */
  public func getSearchableAttributes() async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      self.getSearchableAttributes { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateSearchableAttributes(_:_:)`
   */
  public func updateSearchableAttributes(_ searchableAttribute: [String]) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateSearchableAttributes(searchableAttribute) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetSearchableAttributes(_:)`
   */
  public func resetSearchableAttributes() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetSearchableAttributes { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getDisplayedAttributes(_:)`
   */
  public func getDisplayedAttributes() async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      self.getDisplayedAttributes { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateDisplayedAttributes(_:_:)`
   */
  public func updateDisplayedAttributes(_ displayedAttribute: [String]) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateDisplayedAttributes(displayedAttribute) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetDisplayedAttributes(_:)`
   */
  public func resetDisplayedAttributes() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetDisplayedAttributes { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getFilterableAttributes(_:)`
   */
  public func getFilterableAttributes() async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      self.getFilterableAttributes { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateFilterableAttributes(_:_:)`
   */
  public func updateFilterableAttributes(_ attributes: [String]) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateFilterableAttributes(attributes) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetFilterableAttributes(_:)`
   */
  public func resetFilterableAttributes() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetFilterableAttributes { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getSortableAttributes(_:)`
   */
  public func getSortableAttributes() async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      self.getSortableAttributes { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateSortableAttributes(_:_:)`
   */
  public func updateSortableAttributes(_ attributes: [String]) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateSortableAttributes(attributes) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetSortableAttributes(_:)`
   */
  public func resetSortableAttributes() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetSortableAttributes { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getSeparatorTokens(_:)`
   */
  public func getSeparatorTokens() async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      self.getSeparatorTokens { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateSeparatorTokens(_:_:)`
   */
  public func updateSeparatorTokens(_ attributes: [String]) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateSeparatorTokens(attributes) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetSeparatorTokens(_:)`
   */
  public func resetSeparatorTokens() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetSeparatorTokens { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getNonSeparatorTokens(_:)`
   */
  public func getNonSeparatorTokens() async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      self.getNonSeparatorTokens { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateNonSeparatorTokens(_:_:)`
   */
  public func updateNonSeparatorTokens(_ attributes: [String]) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateNonSeparatorTokens(attributes) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetNonSeparatorTokens(_:)`
   */
  public func resetNonSeparatorTokens() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetNonSeparatorTokens { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getDictionary(_:)`
   */
  public func getDictionary() async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      self.getDictionary { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateDictionary(_:_:)`
   */
  public func updateDictionary(_ attributes: [String]) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateDictionary(attributes) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetDictionary(_:)`
   */
  public func resetDictionary() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetDictionary { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getPaginationSettings(_:)`
   */
  public func getPaginationSettings() async throws -> Pagination {
    try await withCheckedThrowingContinuation { continuation in
      self.getPaginationSettings { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updatePaginationSettings(_:_:)`
   */
  public func updatePaginationSettings(_ settings: Pagination) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updatePaginationSettings(settings) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetPaginationSettings(_:)`
   */
  public func resetPaginationSettings() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetPaginationSettings { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `getTypoTolerance(_:)`
   */
  public func getTypoTolerance() async throws -> TypoToleranceResult {
    try await withCheckedThrowingContinuation { continuation in
      self.getTypoTolerance { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `updateTypoTolerance(_:_:)`
   */
  public func updateTypoTolerance(_ typoTolerance: TypoTolerance) async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.updateTypoTolerance(typoTolerance) { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `resetTypoTolerance(_:)`
   */
  public func resetTypoTolerance() async throws -> TaskInfo {
    try await withCheckedThrowingContinuation { continuation in
      self.resetTypoTolerance { result in
        continuation.resume(with: result)
      }
    }
  }

  /**
   See `stats(_:)`
   */
  public func stats() async throws -> Stat {
    try await withCheckedThrowingContinuation { continuation in
      self.stats { result in
        continuation.resume(with: result)
      }
    }
  }
}
