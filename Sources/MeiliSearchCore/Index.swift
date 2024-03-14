import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/**
 `Index` instances is an entity that gathers a set of documents with its own settings.
 It can be comparable to a table in SQL, or a collection in MongoDB.
 */
public struct Index: Codable, Equatable {
  // MARK: Properties

  /// The index uid.
  public let uid: String
  /// The primary key configured for the index.
  public let primaryKey: String?
  /// The data when the index was created.
  public let createdAt: Date?
  /// The data when the index was last updated.
  public let updatedAt: Date?

  // MARK: Initializers

  init(
    uid: String,
    primaryKey: String? = nil,
    createdAt: Date? = nil,
    updatedAt: Date? = nil
    ) {
    self.uid = uid
    self.primaryKey = primaryKey
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
