import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/**
 `AllStats` instances represent stat of all Indexes.
 */
public struct AllStats: Codable, Equatable {
  // MARK: Properties

  /// Size of the whole database, in bytes.
  public let databaseSize: Int

  /// Date when the server was last updated.
  public let lastUpdate: Date?

  /// Dictionary of all Indexes containing the stat for each Index.
  public let indexes: [String: Stat]
}

/**
 `AllStats` instances represent stat of a specific Index.
 */
public struct Stat: Codable, Equatable {
  // MARK: Properties

  /// Number of documents in the given index.
  public let numberOfDocuments: Int

  /// Returns if the Index is currenly being indexed.
  public let isIndexing: Bool

  /// Usage frequency for each Index field.
  public let fieldDistribution: [String: Int]
}
