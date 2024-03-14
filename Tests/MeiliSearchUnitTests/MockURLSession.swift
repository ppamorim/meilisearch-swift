@testable import MeiliSearch
@testable import MeiliSearchCore
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class MockURLSession: URLSessionProtocol {
  private(set) var nextDataTask = MockURLSessionDataTask()

  private(set) var lastURL: URL?

  private(set) var responses: [ResponsePayload] = []

  func successHttpURLResponse(_ request: URLRequest, _ nextCode: Int) -> URLResponse {
    HTTPURLResponse(url: request.url!, statusCode: nextCode, httpVersion: "HTTP/1.1", headerFields: nil)!
  }

  func failureHttpURLResponse(_ request: URLRequest, _ nextCode: Int) -> URLResponse {
    HTTPURLResponse(url: request.url!, statusCode: nextCode, httpVersion: "HTTP/1.1", headerFields: nil)!
  }

  func execute(with request: URLRequest, completionHandler: @escaping DataTask) -> URLSessionDataTaskProtocol {
    let first: ResponsePayload = !responses.isEmpty ? responses.removeFirst() : ResponsePayload.default
    lastURL = request.url
    nextDataTask.request = request

    if first.nextType == ResponseStatus.success {
      completionHandler(first.nextData, successHttpURLResponse(request, first.nextCode), first.nextError)
    } else {
      completionHandler(first.nextData, failureHttpURLResponse(request, first.nextCode), first.nextError)
    }

    return nextDataTask
  }

  func pushData(_ string: String, code: Int = 200) {
    let payload = ResponsePayload(
      nextType: ResponseStatus.success,
      nextData: string.data(using: .utf8),
      nextError: nil,
      nextCode: code)
    responses.append(payload)
  }

  func pushEmpty(code: Int) {
    let payload = ResponsePayload(
      nextType: ResponseStatus.success,
      nextData: nil,
      nextError: nil,
      nextCode: code)
    responses.append(payload)
  }

  func pushError(_ string: String? = nil, _ error: Error? = nil, code: Int) {
    let payload = ResponsePayload(
      nextType: ResponseStatus.error,
      nextData: string?.data(using: .utf8),
      nextError: error ?? NSError(domain: "", code: code, userInfo: nil),
      nextCode: code)
    responses.append(payload)
  }
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
  var request: URLRequest?
  private (set) var resumeWasCalled = false

  func resume() {
    resumeWasCalled = true
  }
}

enum ResponseStatus {
  case success, error
}

struct ResponsePayload {
  let nextType: ResponseStatus
  let nextData: Data?
  let nextError: Error?
  let nextCode: Int

  static let `default` = ResponsePayload(nextType: ResponseStatus.success, nextData: nil, nextError: nil, nextCode: 200)
}
