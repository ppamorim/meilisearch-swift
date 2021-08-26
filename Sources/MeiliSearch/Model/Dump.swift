import Foundation

/**
 `Dump` instances represent the current status of a dump in the server
 */
public struct Dump: Codable, Equatable {

  // MARK: Properties

  /// Unique identifier and file name of the dump (.dump)
  public let UID: String

  /// Status of the dump creation
  public let status: Status

  // Time when the creation of the dump started
  public let startedAt: String?

  // Time when the creation of the dump completed
  public let finishedAt: String?

  enum CodingKeys: String, CodingKey {
    case UID = "uid"
    case status
    case startedAt
    case finishedAt
  }

  public enum Status: Codable, Equatable {

    case inProgress
    case failed
    case done

    public enum CodingError: Error {
      case unknownStatus
    }

    public init(from decoder: Decoder) throws {
      let container: SingleValueDecodingContainer = try decoder.singleValueContainer()
      let rawStatus: String = try container.decode(String.self)
      switch rawStatus {
      case "in_progress":
        self = Status.inProgress
      case "dump_process_failed":
        self = Status.failed
      case "done":
        self = Status.done
      default:
        throw CodingError.unknownStatus
      }
    }

    public func encode(to encoder: Encoder) throws { }

  }

}
