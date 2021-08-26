import Foundation

/**
 `Version` instances represent the current version of the MeiliSearch server.
 */
public struct Version: Codable, Equatable {

  // MARK: Properties

  /// Current hash from the build.
  public let commitSha: String

  /// Date when the server was compiled.
  public let commitDate: Date

  /// Package version, human readable, overly documented.
  public let pkgVersion: String

}
