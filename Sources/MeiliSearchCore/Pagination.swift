import Foundation

/**
 `Pagination` is a wrapper used in the index pagination setting routes to handle the returned data.
 */
public struct Pagination: Codable, Equatable {
  /// The maximum number of hits (document records) which can be returned by a single search request.
  /// By default, Meilisearch returns 1000 results per search. This limit protects your database from malicious scraping.
  public let maxTotalHits: Int

  public init(maxTotalHits: Int) {
    self.maxTotalHits = maxTotalHits
  }
}
