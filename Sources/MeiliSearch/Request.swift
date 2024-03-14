import Foundation
import MeiliSearchCore

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 Protocol that allows custom implementation of the HTTP layer.
 */
public protocol URLSessionProtocol {
  /// Result for the `execute` function.
  typealias DataTask = (Data?, URLResponse?, Error?) -> Void

  /// Function that will trigger the HTTP request.
  func execute(
    with request: URLRequest,
    completionHandler: @escaping DataTask) -> URLSessionDataTaskProtocol
}

/// URLSessionDataTaskProtocol handler.
public protocol URLSessionDataTaskProtocol {
  /// Trigger HTTP request.
  func resume()
}

enum HTTPMethod: String {
  case get = "GET"
  case put = "PUT"
  case post = "POST"
  case patch = "PATCH"
  case delete = "DELETE"
}

public final class Request {
  private let config: Config
  private let session: URLSessionProtocol
  private let headers: [String: String]

  init(_ config: Config) {
    self.config = config
    self.session = config.session ?? URLSession.shared
    self.headers = config.headers
  }

  func request(
    _ httpMethod: HTTPMethod,
    _ url: URL,
    data: Data? = nil
  ) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod.rawValue
    request.setValue(PackageVersion.qualifiedVersion(), forHTTPHeaderField: "User-Agent")

    if httpMethod != .get {
      request.httpBody = data
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    for (key, value) in headers {
      request.setValue(value, forHTTPHeaderField: key)
    }

    if let apiKey: String = config.apiKey {
      let bearer = "Bearer \(apiKey)"
      request.setValue(bearer, forHTTPHeaderField: "Authorization")
    }

    return request
  }

  func get(
    api: String,
    param: String? = nil,
    _ completion: @escaping (Result<Data?, Swift.Error>) -> Void) {
      var urlString: String = config.url(api: api)
      if let param: String = param, !param.isEmpty {
        urlString += param
      }
      guard let url = URL(string: urlString) else {
        completion(.failure(MeiliSearch.Error.invalidURL(url: urlString)))
        return
      }
      let request = self.request(.get, url)
      let task: URLSessionDataTaskProtocol = session.execute(with: request) { data, response, error in
        do {
          try MeiliSearch.errorHandler(url: url, data: data, response: response, error: error)
          completion(.success(data))
          return
        } catch let error {
          completion(.failure(error))
          return
        }
      }

      task.resume()
  }

  func post(
    api: String,
    param: String? = nil,
    _ data: Data?,
    _ completion: @escaping (Result<Data, Swift.Error>) -> Void) {
    var urlString: String = config.url(api: api)
    if let param: String = param, !param.isEmpty {
      urlString += param
    }
    guard let url = URL(string: urlString) else {
      completion(.failure(MeiliSearch.Error.invalidURL()))
      return
    }

    let request = self.request(.post, url, data: data)
    let task: URLSessionDataTaskProtocol = session.execute(with: request) { data, response, error in
      do {
        try MeiliSearch.errorHandler(url: url, data: data, response: response, error: error)
        if let unwrappedData: Data = data {
          completion(.success(unwrappedData))
          return
        }
        completion(.failure(MeiliSearch.Error.invalidJSON))
      } catch let error {
        completion(.failure(error))
        return
      }
    }

    task.resume()
  }

  func put(
    api: String,
    _ data: Data,
    _ completion: @escaping (Result<Data, Swift.Error>) -> Void) {
    guard let url = URL(string: config.url(api: api)) else {
      completion(.failure(MeiliSearch.Error.invalidURL()))
      return
    }
    let request = self.request(.put, url, data: data)
    let task: URLSessionDataTaskProtocol = session.execute(with: request) { data, response, error in
      do {
        try MeiliSearch.errorHandler(url: url, data: data, response: response, error: error)
        if let unwrappedData: Data = data {
          completion(.success(unwrappedData))
          return
        }
        completion(.failure(MeiliSearch.Error.invalidJSON))
        return
      } catch let error {
        completion(.failure(error))
        return
      }
    }
    task.resume()
  }

  func patch(
    api: String,
    _ data: Data,
    _ completion: @escaping (Result<Data, Swift.Error>) -> Void) {
    guard let url = URL(string: config.url(api: api)) else {
      completion(.failure(MeiliSearch.Error.invalidURL()))
      return
    }
      let request = self.request(.patch, url, data: data)
    let task: URLSessionDataTaskProtocol = session.execute(with: request) { data, response, error in
      do {
        try MeiliSearch.errorHandler(url: url, data: data, response: response, error: error)
        if let unwrappedData: Data = data {
          completion(.success(unwrappedData))
          return
        }
        completion(.failure(MeiliSearch.Error.invalidJSON))
        return
      } catch let error {
        completion(.failure(error))
        return
      }
    }
    task.resume()
  }

  func delete(
    api: String,
    param: String? = nil,
    _ completion: @escaping (Result<Data?, Swift.Error>) -> Void) {
    var urlString: String = config.url(api: api)
    if let param: String = param, !param.isEmpty {
      urlString += param
    }
    guard let url = URL(string: urlString) else {
      completion(.failure(MeiliSearch.Error.invalidURL()))
      return
    }
      let request = self.request(.delete, url)
    let task: URLSessionDataTaskProtocol = session.execute(with: request) { data, response, error in
      do {
        try MeiliSearch.errorHandler(url: url, data: data, response: response, error: error)
        completion(.success(data))
        return
      } catch let error {
        completion(.failure(error))
        return
      }
    }
    task.resume()
  }
}

extension URLSession: URLSessionProtocol {
  public func execute(
    with request: URLRequest,
    completionHandler: @escaping DataTask) -> URLSessionDataTaskProtocol {
    self.dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
  }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
