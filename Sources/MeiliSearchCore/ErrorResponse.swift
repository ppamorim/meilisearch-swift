import Foundation

public struct ErrorResponse: Error, Codable, Hashable {
  /// A human-readable description of the error
  public let message: String

  /// The error code (https://www.meilisearch.com/docs/reference/errors/error_codes)
  public let code: String

  /// The error type (https://www.meilisearch.com/docs/reference/errors/overview#errors)
  public let type: String

  /// A link to the relevant section of the documentation
  public let link: String?

  public init(message: String, code: String, type: String, link: String? = nil) {
    self.message = message
    self.code = code
    self.type = type
    self.link = link
  }
}
