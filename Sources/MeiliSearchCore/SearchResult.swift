import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public class Searchable<T>: Equatable, Codable where T: Codable, T: Equatable {
  public static func == (lhs: Searchable<T>, rhs: Searchable<T>) -> Bool {
    lhs.hits == rhs.hits
  }

  // MARK: Properties

  /// Possible hints from the search query.
  public var hits: [SearchHit<T>] = []

  /// Distribution of the given facets.
  public var facetDistribution: [String: [String: Int]]?

  /// Maximum & minimum stats of a numeric facet.
  public var facetStats: [String: FacetStats]?

  /// Time, in milliseconds, to process the query.
  public var processingTimeMs: Int?

  /// Query string from the search.
  public var query: String?

  public enum CodingKeys: String, CodingKey {
    case hits
    case facetDistribution
    case facetStats
    case processingTimeMs
    case query
  }
}

@dynamicMemberLookup
public struct SearchHit<T>: Equatable, Codable where T: Codable, T: Equatable {
  public let document: T
  public internal(set) var rankingScore: Double?

  /// Dynamic member lookup is used to allow easy access to instance members of the hit result, maintaining a level of backwards compatibility.
  public subscript<V>(dynamicMember keyPath: KeyPath<T, V>) -> V {
    document[keyPath: keyPath]
  }

  // MARK: Codable

  enum CodingKeys: String, CodingKey {
    case rankingScore = "_rankingScore"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.document = try T(from: decoder)
    self.rankingScore = try container.decodeIfPresent(Double.self, forKey: .rankingScore)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(document)

    var containerTwo = encoder.container(keyedBy: CodingKeys.self)
    try containerTwo.encodeIfPresent(rankingScore, forKey: .rankingScore)
  }
}

/**
 `SearchResult` instances represent the result of a search.
 Requires that the value `T` conforms to the `Codable` and `Equatable` protocols.
 */
public class SearchResult<T>: Searchable<T> where T: Codable, T: Equatable {
  // MARK: Properties

  /// Number of documents skipped.
  public var offset: Int = 0

  /// Number of documents taken.
  public var limit: Int = 0

  /// Total number of matches,
  public var estimatedTotalHits: Int = 0

  public enum CodingKeys: String, CodingKey {
    case estimatedTotalHits
    case limit
    case offset
  }

  // This override is required since swift does not parse all the new keys automatically.
  // After this run the result will be a self object + all the keys defined in the Searchable<T>
  public required init(from decoder: Decoder) throws {
    try super.init(from: decoder)

    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.limit = try values.decodeIfPresent(Int.self, forKey: .limit) ?? 0
    self.offset = try values.decodeIfPresent(Int.self, forKey: .offset) ?? 0
    self.estimatedTotalHits = try values.decodeIfPresent(Int.self, forKey: .estimatedTotalHits) ?? 0
  }
}

/**
 `FiniteSearchResult` instances represent the result of a search with finite pagination.
 Requires that the value `T` conforms to the `Codable` and `Equatable` protocols.
 */
public class FiniteSearchResult<T>: Searchable<T> where T: Codable, T: Equatable {
  // MARK: Properties

  /// Number of documents skipped.
  public var totalPages: Int = 0

  /// Number of documents taken.
  public var totalHits: Int = 0

  /// Number of the current page.
  public var page: Int = 0

  /// Max number of hits per page.
  public var hitsPerPage: Int = 0

  public enum CodingKeys: String, CodingKey {
    case totalPages
    case totalHits
    case page
    case hitsPerPage
  }

  // This override is required since swift does not parse all the new keys automatically
  // After this run the result will be a self object + all the keys defined in the Searchable<T>
  public required init(from decoder: Decoder) throws {
    try super.init(from: decoder)

    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.totalHits = try values.decodeIfPresent(Int.self, forKey: .totalHits) ?? 0
    self.totalPages = try values.decodeIfPresent(Int.self, forKey: .totalPages) ?? 0
    self.page = try values.decodeIfPresent(Int.self, forKey: .page) ?? 1
    self.hitsPerPage = try values.decodeIfPresent(Int.self, forKey: .hitsPerPage) ?? 0
  }
}
