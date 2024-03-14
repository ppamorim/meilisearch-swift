import Foundation

/**
 `Task` instances represent the current transaction status, use the `uid` value to
  verify the status of your transaction.
 */
public struct Task: Decodable, Equatable {
  /// Unique ID for the current `Task`.
  public let uid: Int

  /// Unique identifier of the targeted index
  public let indexUid: String?

  /// Returns if the task has been successful or not.
  public let status: Status

  /// Type of the task.
  public let type: TaskType

  /// Details of the task.
  public let details: Details?

  /// Duration of the task process.
  public let duration: String?

  /// Date when the task has been enqueued.
  public let enqueuedAt: Date

  /// Date when the task has been started.
  public let startedAt: Date?

  /// Date when the task has been finished, regardless of status.
  public let finishedAt: Date?

  /// ID of the the `Task` which caused this to be canceled.
  public let canceledBy: Int?

  /// Error information in case of failed update.
  public let error: ErrorResponse?

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(TaskType.self, forKey: .type)

    self.uid = try container.decode(Int.self, forKey: .uid)
    self.indexUid = try container.decodeIfPresent(String.self, forKey: .indexUid)
    self.status = try container.decode(Status.self, forKey: .status)
    self.type = type
    self.duration = try container.decodeIfPresent(String.self, forKey: .duration)
    self.enqueuedAt = try container.decode(Date.self, forKey: .enqueuedAt)
    self.startedAt = try container.decodeIfPresent(Date.self, forKey: .startedAt)
    self.finishedAt = try container.decodeIfPresent(Date.self, forKey: .finishedAt)
    self.canceledBy = try container.decodeIfPresent(Int.self, forKey: .canceledBy)
    self.error = try container.decodeIfPresent(ErrorResponse.self, forKey: .error)

    // we ignore errors thrown by `superDecoder` to handle cases where no details are provided by the API
    // for example when the type is `snapshotCreation`.
    let detailsDecoder = try? container.superDecoder(forKey: .details)
    self.details = try Details(decoder: detailsDecoder, type: type)
  }

  enum CodingKeys: String, CodingKey {
    case uid, indexUid, status, type, details, duration, enqueuedAt, startedAt, finishedAt, canceledBy, error
  }
}
