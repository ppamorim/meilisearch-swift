import Foundation

/**
 `IndexesResults` is a wrapper used in the indexes routes to handle the returned data.
 */

public struct IndexesResults: Codable, Equatable {
  /// Results list containing objects of `Index`.
  public let results: [Index]
  /// Offset the number of records that were skipped in the current response.
  public let offset: Int
  /// Max number of records to be returned in one request.
  public let limit: Int
  /// Total of indexes in the Meilisearch instance.
  public let total: Int
}
