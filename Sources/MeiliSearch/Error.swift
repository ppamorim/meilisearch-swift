import Foundation
import MeiliSearchCore

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/**
 Represent all error types in the client.
 */
public extension MeiliSearch {
  typealias MSErrorResponse = ErrorResponse

  static func errorHandler(url: URL, data: Data?, response: URLResponse?, error: Swift.Error?) throws {
    // Communication Error with Meilisearch
    if let error: Swift.Error = error {
      throw MeiliSearch.Error.meiliSearchCommunicationError(
        message: error.localizedDescription,
        url: url.absoluteString
      )
    }

    guard let response = response as? HTTPURLResponse else {
      fatalError("Correct handles invalid response, please create a custom error type")
    }

    // Error returned by Meilisearch
    if let unwrappedData: Data = data, let res: MeiliSearch.MSErrorResponse = try? Constants.customJSONDecoder.decode(MeiliSearch.MSErrorResponse.self, from: unwrappedData) {
      throw MeiliSearch.Error.meiliSearchApiError(
        message: res.message,
        msErrorResponse: MSErrorResponse(
          message: res.message,
          code: res.code,
          type: res.type,
          link: res.link
        ),
        statusCode: response.statusCode,
        url: url.absoluteString
      )
    }

    // HTTP error with Meilisearch
    if 400 ... 599 ~= response.statusCode {
      throw MeiliSearch.Error.meiliSearchApiError(
        message: HTTPURLResponse.localizedString(forStatusCode: response.statusCode),
        msErrorResponse: nil,
        statusCode: response.statusCode,
        url: url.absoluteString
      )
    }
  }

  /// Generic Error types for Meilisearch,
  enum Error: Swift.Error, LocalizedError, Equatable {
    /// The client tried to contact the server but it was not found.
    case serverNotFound

    /// The client was able to connect the server, send the data nothing returned.
    case dataNotFound

    /// You custom host is invalid.
    case hostNotValid

    /// The input or output JSON is invalid.
    case invalidJSON

    // TimeOut is reached in a waiting function
    case timeOut(timeOut: Double)

    // URL is invalid
    case invalidURL(url: String? = "")

    /// Error originating from Meilisearch API.
    /// case meiliSearchApiError(message: String, code: String, type: String, link: String? = "http://docs.meilisearch.com/errors", underlying: Swift.Error)
    case meiliSearchApiError(message: String, msErrorResponse: MSErrorResponse?, statusCode: Int = 0, url: String = "")

    /// Error communicating with Meilisearch API.
    case meiliSearchCommunicationError(message: String, url: String)

    public var errorDescription: String? {
      switch self {
      case .serverNotFound:
        return "All hosts are unreachable."
      case .dataNotFound:
        return "Missing response data"
      case .hostNotValid:
        return "Response decoding failed"
      case .invalidJSON:
        return "Invalid json"
      case .timeOut(let timeOut):
        return "TimeOut of \(timeOut) is reached"
      case .invalidURL(let url):
        if let strUrl: String = url {
          return "Invalid URL: \(strUrl)"
        }
        return "Invalid URL"
      case .meiliSearchCommunicationError(let message, let url):
        return "meiliSearchCommunicationError \(message) \(url) "

      // can we do let error and then error.message etc...
      case .meiliSearchApiError(let message, let error, let statusCode, let url):
        if let msErrorResponse = error as MSErrorResponse? {
          return """
          MeiliSearchApiError: \(msErrorResponse.message)
          code: \(msErrorResponse.code)
          type: \(msErrorResponse.type)
          link: \(String(describing: msErrorResponse.link))
          status: \(statusCode)
          """
        }
        return "MeiliSearchApiError: \(String(describing: message)) - \(String(describing: statusCode)) - \(String(describing: url))"
      }
    }
  }
}
