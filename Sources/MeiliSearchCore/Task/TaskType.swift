import Foundation

/**
 `TaskType`defines the possible types of task which could be returned by the `/tasks` API
 */
public enum TaskType: Codable, Equatable, LosslessStringConvertible {
  case indexCreation
  case indexUpdate
  case indexDeletion
  case indexSwap
  case documentAdditionOrUpdate
  case documentDeletion
  case settingsUpdate
  case dumpCreation
  case taskCancelation
  case taskDeletion
  case snapshotCreation

  // Captures task types which are not currently known by the Swift package.
  // This allows for a future proofing should the MeiliSearch executable introduce new values.
  case unknown(String)

  public init(from decoder: Decoder) throws {
    let value = try decoder.singleValueContainer().decode(String.self)
    self.init(rawValue: value)
  }

  internal init(rawValue: String) {
    switch rawValue {
    case "indexCreation":
      self = .indexCreation
    case "indexUpdate":
      self = .indexUpdate
    case "indexDeletion":
      self = .indexDeletion
    case "indexSwap":
      self = .indexSwap
    case "documentAdditionOrUpdate":
      self = .documentAdditionOrUpdate
    case "documentDeletion":
      self = .documentDeletion
    case "settingsUpdate":
      self = .settingsUpdate
    case "dumpCreation":
      self = .dumpCreation
    case "taskCancelation":
      self = .taskCancelation
    case "taskDeletion":
      self = .taskDeletion
    case "snapshotCreation":
      self = .snapshotCreation
    default:
      self = .unknown(rawValue)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }

  // MARK: LosslessStringConvertible
  // ensures that when TaskType is converted to String, the "unknown" context is ignored

  public init?(_ description: String) {
    self.init(rawValue: description)
  }

  public var description: String {
    switch self {
    case .indexCreation:
      return "indexCreation"
    case .indexUpdate:
      return "indexUpdate"
    case .indexDeletion:
      return "indexDeletion"
    case .indexSwap:
      return "indexSwap"
    case .documentAdditionOrUpdate:
      return "documentAdditionOrUpdate"
    case .documentDeletion:
      return "documentDeletion"
    case .settingsUpdate:
      return "settingsUpdate"
    case .dumpCreation:
      return "dumpCreation"
    case .taskCancelation:
      return "taskCancelation"
    case .taskDeletion:
      return "taskDeletion"
    case .snapshotCreation:
      return "snapshotCreation"
    case .unknown(let unknownTaskTypeValue):
      return unknownTaskTypeValue
    }
  }
}
