import Foundation

public extension Task {
  enum Details: Equatable {
    case indexCreation(TaskIndexCreationDetails)
    case indexUpdate(TaskIndexUpdateDetails)
    case indexDeletion(TaskIndexDeletionDetails)
    case indexSwap(TaskIndexSwapDetails)
    case documentAdditionOrUpdate(TaskDocumentAdditionOrUpdateDetails)
    case documentDeletion(TaskDocumentDeletionDetails)
    case settingsUpdate(Setting)
    case dumpCreation(TaskDumpCreationDetails)
    case taskCancelation(TaskCancellationDetails)
    case taskDeletion(TaskDeletionDetails)

    init?(decoder: Decoder?, type: TaskType) throws {
      guard let decoder = decoder else {
        return nil
      }

      switch type {
      case .indexCreation:
        self = try .indexCreation(.init(from: decoder))
      case .indexUpdate:
        self = try .indexUpdate(.init(from: decoder))
      case .indexDeletion:
        self = try .indexDeletion(.init(from: decoder))
      case .indexSwap:
        self = try .indexSwap(.init(from: decoder))
      case .documentAdditionOrUpdate:
        self = try .documentAdditionOrUpdate(.init(from: decoder))
      case .documentDeletion:
        self = try .documentDeletion(.init(from: decoder))
      case .settingsUpdate:
        self = try .settingsUpdate(.init(from: decoder))
      case .dumpCreation:
        self = try .dumpCreation(.init(from: decoder))
      case .taskCancelation:
        self = try .taskCancelation(.init(from: decoder))
      case .taskDeletion:
        self = try .taskDeletion(.init(from: decoder))
      case .snapshotCreation:
        // as per documentation: "The details object is set to null for snapshotCreation tasks."
        return nil
      case .unknown:
        // we do not handle this type, and as such even if details exist we do not support them here
        return nil
      }
    }
  }

  struct TaskDocumentAdditionOrUpdateDetails: Decodable, Equatable {
    /// Number of documents sent
    public let receivedDocuments: Int?

    /// Number of documents successfully indexed/updated in Meilisearch
    public let indexedDocuments: Int?
  }

  struct TaskDocumentDeletionDetails: Decodable, Equatable {
    /// Number of documents queued for deletion
    public let providedIds: Int?
    /// The filter used to delete documents. nil if it was not specified
    public let originalFilter: String?
    /// Number of documents deleted. nil while the task status is enqueued or processing
    public let deletedDocuments: Int?
  }

  struct TaskIndexCreationDetails: Decodable, Equatable {
    /// Value of the primaryKey field supplied during index creation. nil if it was not specified
    public let primaryKey: String?
  }

  struct TaskIndexUpdateDetails: Decodable, Equatable {
    /// Value of the primaryKey field supplied during index update. nil if it was not specified
    public let primaryKey: String?
  }

  struct TaskIndexDeletionDetails: Decodable, Equatable {
    /// Number of deleted documents. This should equal the total number of documents in the deleted index. nil while the task status is enqueued or processing
    public let deletedDocuments: Int?
  }

  struct TaskIndexSwapDetails: Decodable, Equatable {
    /// Object containing the payload for the indexSwap task
    public let swaps: [SwapIndexPayload]
  }

  struct TaskCancellationDetails: Decodable, Equatable {
    /// The number of matched tasks. If the API key used for the request doesn’t have access to an index, tasks relating to that index will not be included in matchedTasks
    public let matchedTasks: Int?
      /// The number of tasks successfully canceled. If the task cancelation fails, this will be 0. nil when the task status is enqueued or processing
    public let canceledTasks: Int?
      /// The filter used in the cancel task request
    public let originalFilter: String?
  }

  struct TaskDeletionDetails: Decodable, Equatable {
    /// The number of matched tasks. If the API key used for the request doesn’t have access to an index, tasks relating to that index will not be included in matchedTasks
    public let matchedTasks: Int?
    /// The number of tasks successfully deleted. If the task deletion fails, this will be 0. nil when the task status is enqueued or processing
    public let deletedTasks: Int?
    /// The filter used in the delete task request
    public let originalFilter: String?
  }

  struct TaskDumpCreationDetails: Decodable, Equatable {
    /// The generated uid of the dump. This is also the name of the generated dump file. nil when the task status is enqueued, processing, canceled, or failed
    public let dumpUid: String?
  }
}
