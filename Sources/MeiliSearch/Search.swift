import Foundation
import MeiliSearchCore

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct Search {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  func search<T>(
    _ uid: String,
    _ searchParameters: SearchParameters,
    _ completion: @escaping (Result<Searchable<T>, Swift.Error>) -> Void)
  where T: Decodable {
    let data: Data
    do {
      data = try JSONEncoder().encode(searchParameters)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    self.request.post(api: "/indexes/\(uid)/search", data) { result in
      switch result {
      case .success(let data):
        do {
          let decoder: JSONDecoder = Constants.customJSONDecoder

          if searchParameters.hitsPerPage != nil || searchParameters.page != nil {
            completion(.success(try decoder.decode(FiniteSearchResult<T>.self, from: data)))
          } else {
            completion(.success(try decoder.decode(SearchResult<T>.self, from: data)))
          }
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
