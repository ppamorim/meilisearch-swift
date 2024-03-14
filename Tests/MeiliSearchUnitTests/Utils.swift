import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
import XCTest
@testable import MeiliSearch
@testable import MeiliSearchCore

public let TESTS_TIME_OUT = 10.0

func decodeJSON<T: Decodable>(from string: String) throws -> T {
  let data = Data(string.utf8)
  return try Constants.customJSONDecoder.decode(T.self, from: data)
}
