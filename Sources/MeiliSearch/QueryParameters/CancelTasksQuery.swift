import Foundation
import MeiliSearchCore

/**
 `CancelTasksQuery` class represent the options used to filter a cancel tasks call.
 */
public class CancelTasksQuery: Queryable {
  /// List of strings with all the types the response should contain.
  public let types: [TaskType]
  /// List of strings with all the statuses the response should contain.
  public let statuses: [Task.Status]
  /// Filter tasks response by a particular list of index Uids strings
  public let indexUids: [String]
  /// Filter tasks based on a list of task's uids.
  public let uids: [Int]
  /// Filter tasks based on the date before the task were enqueued at.
  public let beforeEnqueuedAt: Date?
  /// Filter tasks based on the date after the task were enqueued at.
  public let afterEnqueuedAt: Date?
  /// Filter tasks based on the date before the task were started.
  public let beforeStartedAt: Date?
  /// Filter tasks based on the date after the task were started at.
  public let afterStartedAt: Date?

  init(
    types: [TaskType]? = nil, statuses: [Task.Status]? = nil,
    indexUids: [String]? = nil, uids: [Int]? = nil,
    beforeEnqueuedAt: Date? = nil, afterEnqueuedAt: Date? = nil,
    beforeStartedAt: Date? = nil, afterStartedAt: Date? = nil
  ) {
    self.types = types ?? []
    self.statuses = statuses ?? []
    self.indexUids = indexUids ?? []
    self.uids = uids ?? []
    self.beforeEnqueuedAt = beforeEnqueuedAt
    self.afterEnqueuedAt = afterEnqueuedAt
    self.beforeStartedAt = beforeStartedAt
    self.afterStartedAt = afterStartedAt
  }

  internal func buildQuery() -> [String: Codable?] {
    [
      "uids": uids.isEmpty ? nil : uids.map(String.init).joined(separator: ","),
      "types": types.isEmpty ? nil : types.map({ $0.description }).joined(separator: ","),
      "statuses": statuses.isEmpty ? nil : statuses.map({ $0.rawValue }).joined(separator: ","),
      "indexUids": indexUids.isEmpty ? nil : indexUids.joined(separator: ","),
      "beforeEnqueuedAt": Formatter.formatOptionalDate(date: beforeEnqueuedAt),
      "afterEnqueuedAt": Formatter.formatOptionalDate(date: afterEnqueuedAt),
      "beforeStartedAt": Formatter.formatOptionalDate(date: beforeStartedAt),
    ]
  }
}
