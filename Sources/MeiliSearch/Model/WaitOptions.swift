import Foundation

/**
 `WaitOptions` struct represent the options used during a waitForPendingUpdate call.
 */
public struct WaitOptions: Codable, Equatable {

  // MARK: Properties

  /// Maximum time in seconds before cancel
  public let timeOut: Double

  /// Interval in seconds between each status call
  public let interval: Double

  // MARK: Initializers
  public init(
    timeOut: Double? = 5,
    interval: Double? = 0.05
  ) {
    self.timeOut = timeOut ?? 5
    self.interval = interval ?? 0.05
  }

  // MARK: Codable Keys

  enum CodingKeys: String, CodingKey {
    case timeOut
    case interval
  }

}
