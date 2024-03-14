import Foundation

public extension Task {
  enum Status: String, Codable, Equatable {
    /// When a task was successfully enqueued and is waiting to be processed.
    case enqueued
    /// When a task is still being processed.
    case processing
    /// When a task was successfully processed.
    case succeeded
    /// When a task had an error and could not be completed for some reason.
    case failed
    /// When a task has been canceled.
    case canceled

    public enum StatusError: Error {
      case unknown
    }

    public init(from decoder: Decoder) throws {
      let container: SingleValueDecodingContainer = try decoder.singleValueContainer()
      let rawStatus: String = try container.decode(String.self)

      switch rawStatus {
      case "enqueued":
        self = Status.enqueued
      case "processing":
        self = Status.processing
      case "succeeded":
        self = Status.succeeded
      case "failed":
        self = Status.failed
      case "canceled":
        self = Status.canceled
      default:
        throw StatusError.unknown
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(rawValue)
    }
  }
}
