import Foundation
import MeiliSearchCore

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/**
  Tasks contains information related to asynchronous tasks in MeiliSearch
 */
struct Tasks {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  // Get on client
  func get(
    taskUid: Int,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      get(path: "/tasks/\(taskUid)", completion)
  }

  private func get (
    path: String,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      self.request.get(api: path) { result in
        switch result {
        case .success(let data):
          do {
            let task: Result<Task, Swift.Error>  = try Constants.resultDecoder(data: data)
            completion(task)
          } catch {
            completion(.failure(error))
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }

  // get all on client
  func getTasks(
    params: TasksQuery? = nil,
    _ completion: @escaping (Result<TasksResults, Swift.Error>) -> Void) {
      listTasks(params: params, completion)
  }

  // get all on index
  func getTasks(
    uid: String,
    params: TasksQuery? = nil,
    _ completion: @escaping (Result<TasksResults, Swift.Error>) -> Void) {
      var query: TasksQuery?

      if params != nil {
        params?.indexUids.append(uid)

        query = params
      } else {
        query = TasksQuery(indexUids: [uid])
      }

      listTasks(params: query, completion)
  }

  private func listTasks(
    params: TasksQuery? = nil,
    _ completion: @escaping (Result<TasksResults, Swift.Error>) -> Void) {
    self.request.get(api: "/tasks", param: params?.toQuery()) { result in
      switch result {
      case .success(let data):
        do {
          let task: Result<TasksResults, Swift.Error> = try Constants.resultDecoder(data: data)

          completion(task)
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  private func checkStatus(
    _ taskUid: Int,
    _ options: WaitOptions,
    _ startingDate: Date,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      self.get(taskUid: taskUid) { result in
        switch result {
        case .success(let status):
          if status.status == Task.Status.succeeded || status.status == Task.Status.failed {
            completion(.success(status))
          } else if 0 - startingDate.timeIntervalSinceNow > options.timeOut {
            completion(.failure(MeiliSearch.Error.timeOut(timeOut: options.timeOut)))
          } else {
            usleep(useconds_t(options.interval * 1000000))
            self.checkStatus(taskUid, options, startingDate, completion)
          }
        case .failure(let error):
          completion(.failure(error))
          return
        }
      }
  }

  // wait for task using task structure
  func waitForTask(
    task: Task,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      waitForTask(taskUid: task.uid, options: options, completion)
  }

  // wait for task using taskUid
  func waitForTask(
    taskUid: Int,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      do {
        let currentDate = Date()
        let waitOptions = options ?? WaitOptions()

        self.checkStatus(taskUid, waitOptions, currentDate) { result in
          switch result {
          case .success(let status):
            completion(.success(status))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }
  }

  // MARK: Cancel Tasks

  func cancelTasks(
    _ params: CancelTasksQuery,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.request.post(api: "/tasks/cancel", param: params.toQuery(), nil) { result in
      switch result {
      case .success(let data):
        do {
          let task: Result<TaskInfo, Swift.Error> = try Constants.resultDecoder(data: data)
          completion(task)
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // MARK: Delete Tasks

  func deleteTasks(
    _ params: DeleteTasksQuery,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.request.delete(api: "/tasks", param: params.toQuery()) { result in
      switch result {
      case .success(let data):
        do {
          let task: Result<TaskInfo, Swift.Error> = try Constants.resultDecoder(data: data)
          completion(task)
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
