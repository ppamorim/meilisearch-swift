import Foundation
import MeiliSearchCore

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct Stats {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  func stats(
    _ uid: String,
    _ completion: @escaping (Result<Stat, Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/stats") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let stat: Stat = try Constants.customJSONDecoder.decode(Stat.self, from: data)
          completion(.success(stat))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func allStats(_ completion: @escaping (Result<AllStats, Swift.Error>) -> Void) {
    self.request.get(api: "/stats") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let allStats: AllStats = try Constants.customJSONDecoder.decode(AllStats.self, from: data)
          completion(.success(allStats))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
