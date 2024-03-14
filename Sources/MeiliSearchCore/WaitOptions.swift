import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/**
 `WaitOptions` struct represent the options used during a waitForTask call.
 */
public struct WaitOptions: Codable, Equatable {
  // MARK: Properties

  /// Maximum time in seconds before timeOut
  public let timeOut: Double

  /// Interval in seconds between each status call
  public let interval: TimeInterval

  // MARK: Initializers
  public init(
    timeOut: Double? = 5,
    interval: TimeInterval? = 0.5
  ) {
    self.timeOut = timeOut ?? 5
    self.interval = interval ?? 0.5
  }
}
