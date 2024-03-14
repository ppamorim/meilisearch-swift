import Foundation

public struct UpdateIndexPayload: Codable {
  public let primaryKey: String

  public init(primaryKey: String) {
    self.primaryKey = primaryKey
  }
}

public struct CreateIndexPayload: Codable {
  public let uid: String
  public let primaryKey: String?

  public init(uid: String, primaryKey: String? = nil) {
    self.uid = uid
    self.primaryKey = primaryKey
  }
}

public struct SwapIndexPayload: Codable, Equatable {
  public let indexes: [String]

  public init(indexes: [String]) {
    self.indexes = indexes
  }
}
