import Foundation
import MeiliSearchCore

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

struct Keys {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  func get(key: String, _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    self.request.get(api: "/keys/\(key)") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let decoder = Constants.customJSONDecoder
          let key: Key = try decoder.decode(Key.self, from: data)
          completion(.success(key))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func getAll(params: KeysQuery?, _ completion: @escaping (Result<KeysResults, Swift.Error>) -> Void) {
    self.request.get(api: "/keys", param: params?.toQuery()) { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let keys = try Constants.customJSONDecoder.decode(KeysResults.self, from: data)

          completion(.success(keys))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func create(
    _ keyParams: KeyParams,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    let data: Data
    do {
      data = try Constants.customJSONEecoder.encode(keyParams)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }
    self.request.post(api: "/keys", data) { result in
      switch result {
      case .success(let result):
      do {
        let key: Key = try Constants.customJSONDecoder.decode(
          Key.self,
          from: result)
          completion(.success(key))
      } catch {
        completion(.failure(error))
      }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func update(
    keyOrUid: String,
    keyParams: KeyUpdateParams,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    let data: Data
    do {
      let encoder = JSONEncoder()
      data = try encoder.encode(keyParams)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    self.request.patch(api: "/keys/\(keyOrUid)", data) { result in
      switch result {
      case .success(let result):
      do {
        let key: Key = try Constants.customJSONDecoder.decode(
          Key.self,
          from: result)
          completion(.success(key))
      } catch {
        completion(.failure(error))
      }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func delete(
    keyOrUid: String,
    _ completion: @escaping (Result<(), Swift.Error>) -> Void) {
    self.request.delete(api: "/keys/\(keyOrUid)") { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
