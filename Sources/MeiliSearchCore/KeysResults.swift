import Foundation

/**
 `KeysResults` is a wrapper used in the keys routes to handle the returned data.
 */

public struct KeysResults: Codable, Equatable {
  /// Results list containing `Key` objects.
  public let results: [Key]
  /// Offset the number of records that were skipped in the current response.
  public let offset: Int
  /// Max number of documents to be returned in one request.
  public let limit: Int
  /// Total of documents present in the index.
  public let total: Int
}
