import Foundation
import MeiliSearchCore

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 The dumps route allows the creation of database dumps. Dumps are `.tar.gz` files that
 can be used to launch Meilisearch. Dumps are compatible between Meilisearch versions.
 */
struct Dumps {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  // MARK: Create

  func create(_ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.request.post(api: "/dumps", Data()) { result in
      switch result {
      case .success(let data):
        do {
          let result: TaskInfo = try Constants.customJSONDecoder.decode(TaskInfo.self, from: data)
          completion(.success(result))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
