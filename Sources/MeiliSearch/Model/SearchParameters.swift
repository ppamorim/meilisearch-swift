import Foundation

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

  /// Document attributes to show.
  public let attributesToRetrieve: [String]?

  /// Which attributes to crop.
  public let attributesToCrop: [String]?

  /// Limit length at which to crop specified attributes.
  public let cropLength: Int?

  /// Which attributes to highlight.
  public let attributesToHighlight: [String]?

  /// Filter on attributes values.
  public let filter: String?

  /// Retrieve the count of matching terms for each facets.
  public let facetsDistribution: [String]?

  /// Whether to return the raw matches or not.
  public let matches: Bool?

  // MARK: Initializers

  public init(
    query: String?,
    offset: Int? = nil,
    limit: Int? = nil,
    attributesToRetrieve: [String]? = nil,
    attributesToCrop: [String]? = nil,
    cropLength: Int? = nil,
    attributesToHighlight: [String]? = nil,
    filter: String? = nil,
    facetsDistribution: [String]? = nil,
    matches: Bool? = false) {
    self.query = query
    self.offset = offset
    self.limit = limit
    self.attributesToRetrieve = attributesToRetrieve
    self.attributesToCrop = attributesToCrop
    self.cropLength = cropLength
    self.attributesToHighlight = attributesToHighlight
    self.filter = filter
    self.facetsDistribution = facetsDistribution
    self.matches = matches
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
    case cropLength
    case attributesToHighlight
    case filter
    case facetsDistribution
    case matches
  }

}
