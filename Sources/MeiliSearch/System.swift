import Foundation
import MeiliSearchCore

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

struct System {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init(_ request: Request) {
    self.request = request
  }

  // MARK: Functions

  func health(_ completion: @escaping (Result<Health, Swift.Error>) -> Void) {
    request.get(api: "/health") { result in
      switch result {
      case .success(let data):
        guard let data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let vesion: Health = try Constants.customJSONDecoder.decode(Health.self, from: data)

          completion(.success(vesion))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func version(_ completion: @escaping (Result<Version, Swift.Error>) -> Void) {
    request.get(api: "/version") { result in
      switch result {
      case .success(let data):
        guard let data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let vesion: Version = try Constants.customJSONDecoder.decode(Version.self, from: data)

          completion(.success(vesion))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
