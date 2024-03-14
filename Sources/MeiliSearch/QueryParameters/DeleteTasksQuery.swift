import Foundation
import MeiliSearchCore

/**
 `DeleteTasksQuery` class represent the options used to filter a delete tasks call.
 */
public class DeleteTasksQuery: Queryable {
  /// List of strings with all the types the response should contain.
  public let types: [TaskType]
  /// List of strings with all the statuses the response should contain.
  public let statuses: [Task.Status]
  /// Filter tasks response by a particular list of index Uids strings
  public let indexUids: [String]
  /// Filter tasks based on a list of task's uids.
  public let uids: [Int]
  /// Filter tasks based on a list of task's uids which were used to cancel other tasks.
  public let canceledBy: [Int]
  /// Filter tasks based on the date before the task were enqueued at.
  public let beforeEnqueuedAt: Date?
  /// Filter tasks based on the date after the task were enqueued at.
  public let afterEnqueuedAt: Date?
  /// Filter tasks based on the date before the task were started.
  public let beforeStartedAt: Date?
  /// Filter tasks based on the date after the task were started at.
  public let afterStartedAt: Date?
  /// Filter tasks based on the date before the task was finished.
  public let beforeFinishedAt: Date?
  /// Filter tasks based on the date after the task was finished.
  public let afterFinishedAt: Date?

  init(
    statuses: [Task.Status]? = nil, types: [TaskType]? = nil,
    indexUids: [String]? = nil, uids: [Int]? = nil, canceledBy: [Int]? = nil,
    beforeEnqueuedAt: Date? = nil, afterEnqueuedAt: Date? = nil,
    beforeStartedAt: Date? = nil, afterStartedAt: Date? = nil,
    beforeFinishedAt: Date? = nil, afterFinishedAt: Date? = nil
  ) {
    self.statuses = statuses ?? []
    self.types = types ?? []
    self.indexUids = indexUids ?? []
    self.uids = uids ?? []
    self.canceledBy = canceledBy ?? []
    self.beforeEnqueuedAt = beforeEnqueuedAt
    self.afterEnqueuedAt = afterEnqueuedAt
    self.beforeStartedAt = beforeStartedAt
    self.afterStartedAt = afterStartedAt
    self.beforeFinishedAt = beforeFinishedAt
    self.afterFinishedAt = afterFinishedAt
  }

  internal func buildQuery() -> [String: Codable?] {
    [
      "uids": uids.isEmpty ? nil : uids.map(String.init).joined(separator: ","),
      "types": types.isEmpty ? nil : types.map({ $0.description }).joined(separator: ","),
      "statuses": statuses.isEmpty ? nil : statuses.map({ $0.rawValue }).joined(separator: ","),
      "indexUids": indexUids.isEmpty ? nil : indexUids.joined(separator: ","),
      "canceledBy": canceledBy.isEmpty ? nil : canceledBy.map(String.init).joined(separator: ","),
      "beforeEnqueuedAt": Formatter.formatOptionalDate(date: beforeEnqueuedAt),
      "afterEnqueuedAt": Formatter.formatOptionalDate(date: afterEnqueuedAt),
      "beforeStartedAt": Formatter.formatOptionalDate(date: beforeStartedAt),
      "beforeFinishedAt": Formatter.formatOptionalDate(date: beforeFinishedAt),
      "afterFinishedAt": Formatter.formatOptionalDate(date: afterFinishedAt),
    ]
  }
}
