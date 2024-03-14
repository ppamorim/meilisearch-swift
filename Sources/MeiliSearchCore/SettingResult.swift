/**
  Returned Setting object with avoided nil values
 */
public struct SettingResult: Codable, Equatable {
  // MARK: Properties

  /// List of ranking rules for a given `Index`.
  public let rankingRules: [String]

  /// List of searchable attributes for a given `Index`.
  public let searchableAttributes: [String]

  /// List of displayed attributes for a given `Index`.
  public let displayedAttributes: [String]

  /// List of stop-words for a given `Index`.
  public let stopWords: [String]

  /// List of synonyms and its values for a given `Index`.
  public let synonyms: [String: [String]]

  /// Optional distinct attribute set for a given `Index`.
  public let distinctAttribute: String?

  /// List of attributes used for filtering
  public let filterableAttributes: [String]

  /// List of attributes used for sorting
  public let sortableAttributes: [String]

  /// List of tokens that will be considered as word separators by Meilisearch.
  public let separatorTokens: [String]

  /// List of tokens that will not be considered as word separators by Meilisearch.
  public let nonSeparatorTokens: [String]

  /// List of words on which the segmentation will be overridden.
  public let dictionary: [String]

  /// Pagination settings for the current index
  public let pagination: Pagination

  /// Settings for typo tolerance
  public let typoTolerance: TypoToleranceResult
}
