import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/**
 `Health` instances represent the status of the Meilisearch server.
 */
public struct Health: Codable, Equatable {
  // MARK: Properties

  /// Status of the Meilisearch server
  public let status: String
}
