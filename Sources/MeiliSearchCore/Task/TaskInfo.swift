import Foundation

/**
 `TaskInfo` instances represent the current transaction status, use the `taskUid` value to
  verify the status of your transaction.
 */
public struct TaskInfo: Codable, Equatable {
  /// Unique ID for the current `TaskInfo`.
  public let taskUid: Int

  /// Unique ID for the current `TaskInfo`.
  public let indexUid: String?

  /// Returns if the task has been successful or not.
  public let status: Task.Status

  /// Type of the task.
  public let type: TaskType

  /// Date when the task has been enqueued.
  public let enqueuedAt: Date

  public enum CodingKeys: String, CodingKey {
    case taskUid, indexUid, status, type, enqueuedAt
  }
}
