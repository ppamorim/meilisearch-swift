import Foundation
import MeiliSearchCore

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct Documents {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  func get<T>(
    _ uid: String,
    _ identifier: String,
    fields: [String]? = nil,
    _ completion: @escaping (Result<T, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    var path: String = "/indexes/\(uid)/documents/\(identifier)"

    if fields != nil {
      let fieldsQuery = "?fields=\(fields?.joined(separator: ",") ?? "")"
      path.append(fieldsQuery)
    }

    self.request.get(api: path) { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        Documents.decodeJSON(data, completion: completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func getAll<T>(
    _ uid: String,
    params: DocumentsQuery? = nil,
    _ completion: @escaping (Result<DocumentsResults<T>, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    let pathParams = params?.toQuery() ?? ""

    request.get(api: "/indexes/\(uid)/documents\(pathParams)") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        Documents.decodeJSON(data, completion: completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // MARK: Write

  func add(
    _ uid: String,
    _ document: Data,
    _ primaryKey: String? = nil,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    var path: String = "/indexes/\(uid)/documents"
    if let primaryKey: String = primaryKey {
      path += "?primaryKey=\(primaryKey)"
    }

    request.post(api: path, document) { result in
      switch result {
      case .success(let data):
        Documents.decodeJSON(data, completion: completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func add<T>(
    _ uid: String,
    _ documents: [T],
    _ encoder: JSONEncoder? = nil,
    _ primaryKey: String? =  nil,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) where T: Encodable {
    var path: String = "/indexes/\(uid)/documents"
    if let primaryKey: String = primaryKey {
      path += "?primaryKey=\(primaryKey)"
    }

    let data: Data!
    switch encodeJSON(documents, encoder) {
    case .success(let documentData):
      data = documentData
    case .failure(let error):
      completion(.failure(error))
      return
    }

    request.post(api: path, data) { result in
      switch result {
      case .success(let data):
        Documents.decodeJSON(data, completion: completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func update(
    _ uid: String,
    _ document: Data,
    _ primaryKey: String? = nil,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    var path: String = "/indexes/\(uid)/documents"
    if let primaryKey: String = primaryKey {
      path += "?primaryKey=\(primaryKey)"
    }

    request.put(api: path, document) { result in
      switch result {
      case .success(let data):
        Documents.decodeJSON(data, completion: completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func update<T>(
    _ uid: String,
    _ documents: [T],
    _ encoder: JSONEncoder? = nil,
    _ primaryKey: String? =  nil,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) where T: Encodable {

    var path: String = "/indexes/\(uid)/documents"
    if let primaryKey: String = primaryKey {
      path += "?primaryKey=\(primaryKey)"
    }

    let data: Data!
    switch encodeJSON(documents, encoder) {
    case .success(let documentData):
      data = documentData
    case .failure(let error):
      completion(.failure(error))
      return
    }

    request.put(api: path, data) { result in
      switch result {
      case .success(let data):
        Documents.decodeJSON(data, completion: completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // MARK: Delete

  func delete(
    _ uid: String,
    _ identifier: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/documents/\(identifier)") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        Documents.decodeJSON(data, completion: completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func deleteAll(
    _ uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/documents") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        Documents.decodeJSON(data, completion: completion)

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func deleteBatch(
    _ uid: String,
    _ documentsIdentifiers: [String],
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {

    let data: Data

    do {
      data = try JSONSerialization.data(withJSONObject: documentsIdentifiers, options: [])
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    self.request.post(api: "/indexes/\(uid)/documents/delete-batch", data) { result in
      switch result {
      case .success(let data):

        Documents.decodeJSON(data, completion: completion)

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  private static func decodeJSON<T: Codable>(
    _ data: Data,
    _ customDecoder: JSONDecoder? = nil,
    completion: (Result<T, Swift.Error>) -> Void) {
    do {
      let decoder: JSONDecoder = customDecoder ?? Constants.customJSONDecoder
      let value: T = try decoder.decode(T.self, from: data)
      completion(.success(value))
    } catch {
      completion(.failure(error))
    }
  }

  private func encodeJSON<T: Encodable>(
    _ documents: [T],
    _ encoder: JSONEncoder?) -> Result<Data, Swift.Error> {
    do {
      let data: Data = try (encoder ?? Constants.customJSONEecoder)
        .encode(documents)
      return .success(data)
    } catch {
      return .failure(error)
    }
  }
}
