import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/**
 `SearchParameters` instances represent query setup for a search request.
 Use `SearchParameters.query` to directly create a search query with the
 default search configuration.
 */
public struct SearchParameters: Codable, Equatable {
  // MARK: Properties

  /// Query string (mandatory).
  public let query: String?

  /// Number of documents to take.
  public let limit: Int?

  /// Number of documents to skip.
  public let offset: Int?

  /// Number of documents to take per page.
  public let hitsPerPage: Int?

  /// Page number to show.
  public let page: Int?

  /// Document attributes to show.
  public let attributesToRetrieve: [String]?

  /// Which attributes to crop.
  public let attributesToCrop: [String]?

  /// Attributes to search on.
  public let attributesToSearchOn: [String]?

  /// Limit length at which to crop specified attributes.
  public let cropLength: Int?

  /// Marker in front and behind a cropped value.
  public let cropMarker: String?

  /// Which attributes to highlight.
  public let attributesToHighlight: [String]?

  /// Tag in front of highlighted term(s).
  public let highlightPreTag: String?

  /// Tag at the end of highlighted term(s).
  public let highlightPostTag: String?

  /// Filter on attributes values.
  public let filter: String?

  /// Filter on attributes values.
  public let sort: [String]?

  /// Retrieve the count of matching terms for each facets.
  public let facets: [String]?

  /// Whether to return the raw matches or not.
  public let showMatchesPosition: Bool?

  /// Whether to return the search ranking score or not.
  public let showRankingScore: Bool?

  // MARK: Initializers

  public init(
    query: String?,
    offset: Int? = nil,
    limit: Int? = nil,
    page: Int? = nil,
    hitsPerPage: Int? = nil,
    attributesToRetrieve: [String]? = nil,
    attributesToCrop: [String]? = nil,
    attributesToSearchOn: [String]? = nil,
    cropLength: Int? = nil,
    cropMarker: String? = nil,
    attributesToHighlight: [String]? = nil,
    highlightPreTag: String? = nil,
    highlightPostTag: String? = nil,
    filter: String? = nil,
    sort: [String]? = nil,
    facets: [String]? = nil,
    showMatchesPosition: Bool? = nil,
    showRankingScore: Bool? = nil) {
    self.query = query
    self.offset = offset
    self.limit = limit
    self.hitsPerPage = hitsPerPage
    self.page = page
    self.attributesToRetrieve = attributesToRetrieve
    self.attributesToCrop = attributesToCrop
    self.attributesToSearchOn = attributesToSearchOn
    self.cropLength = cropLength
    self.cropMarker = cropMarker
    self.attributesToHighlight = attributesToHighlight
    self.highlightPreTag = highlightPreTag
    self.highlightPostTag = highlightPostTag
    self.filter = filter
    self.sort = sort
    self.facets = facets
    self.showMatchesPosition = showMatchesPosition
    self.showRankingScore = showRankingScore
  }

  // MARK: Query Initializers

  /**
   Minimal static function used to easily initialize the `SearchParameters` instance with
   the search query applied.

   - parameter value: Query string (mandatory).
   */
  public static func query(_ value: String) -> SearchParameters {
    SearchParameters(query: value)
  }

  // MARK: Codable Keys

  enum CodingKeys: String, CodingKey {
    case query = "q"
    case offset
    case limit
    case attributesToRetrieve
    case attributesToCrop
    case attributesToSearchOn
    case cropLength
    case cropMarker
    case attributesToHighlight
    case highlightPreTag
    case highlightPostTag
    case filter
    case sort
    case facets
    case showMatchesPosition
    case hitsPerPage
    case page
    case showRankingScore
  }
}
