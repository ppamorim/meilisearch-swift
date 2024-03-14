import Foundation

/**
 `DocumentsResults` is a wrapper used in the documents routes to handle the returned data.
 */

public struct DocumentsResults<T: Decodable & Encodable & Equatable>: Codable, Equatable {
  /// Results list containing objects of `T`.
  public let results: [T]
  /// Offset the number of records that were skipped in the current response.
  public let offset: Int
  /// Max number of documents to be returned in one request.
  public let limit: Int
  /// Total of documents present in the index.
  public let total: Int
}
