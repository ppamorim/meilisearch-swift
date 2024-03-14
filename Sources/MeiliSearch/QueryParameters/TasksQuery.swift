import Foundation
import MeiliSearchCore

/**
 `TasksQuery` class represent the options used to filter a get tasks call.
 */

public class TasksQuery: Queryable {
  // MARK: Properties

  /// Integer value representing the first `uid` of the first task returned.
  private var from: Int?
  /// Max number of indexes to be returned in one request.
  private var limit: Int?
  /// Integer value used to retrieve the next batch of tasks.
  private var next: Int?
  /// List of strings with all the types the response should contain.
  private var types: [TaskType]
  /// List of strings with all the statuses the response should contain.
  private var statuses: [Task.Status]
  /// Filter tasks response by a particular list of index Uids strings
  var indexUids: [String]
  /// Filter tasks based on a list of task's uids.
  private var uids: [Int]
  /// Filter tasks based on a list of task's uids which were used to cancel other tasks.
  private var canceledBy: [Int]
  /// Filter tasks based on the date before the task were enqueued at.
  private var beforeEnqueuedAt: Date?
  /// Filter tasks based on the date after the task were enqueued at.
  private var afterEnqueuedAt: Date?
  /// Filter tasks based on the date before the task were started.
  private var beforeStartedAt: Date?
  /// Filter tasks based on the date after the task were started at.
  private var afterStartedAt: Date?
  /// Filter tasks based on the date before the task was finished.
  private var beforeFinishedAt: Date?
  /// Filter tasks based on the date after the task was finished.
  private var afterFinishedAt: Date?

  init(
    limit: Int? = nil, from: Int? = nil, next: Int? = nil,
    statuses: [Task.Status]? = nil, types: [TaskType]? = nil,
    indexUids: [String]? = nil, uids: [Int]? = nil, canceledBy: [Int]? = nil,
    beforeEnqueuedAt: Date? = nil, afterEnqueuedAt: Date? = nil,
    afterFinishedAt: Date? = nil, beforeStartedAt: Date? = nil,
    afterStartedAt: Date? = nil, beforeFinishedAt: Date? = nil
  ) {
    self.from = from
    self.limit = limit
    self.next = next
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
      "limit": limit,
      "from": from,
      "next": next,
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
