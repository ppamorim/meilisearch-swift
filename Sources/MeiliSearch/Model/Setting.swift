import Foundation

/**
  Settings object provided byb the user
 */
public struct Setting: Codable, Equatable {

  // MARK: Properties

  /// List of ranking rules for a given `Index`.
  public let rankingRules: [String]

  /// List of searchable attributes for a given `Index`.
  public let searchableAttributes: [String]

  /// List of displayed attributes for a given `Index`.
  public let displayedAttributes: [String]

  /// List of stop-words for a given `Index`.
  public let stopWords: [String]?

  /// List of synonyms and its values for a given `Index`.
  public let synonyms: [String: [String]]?

  /// Optional distinct attribute set for a given `Index`.
  public let distinctAttribute: String?

  /// List of attributes used for filtering
  public let filterableAttributes: [String]

}

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

}

extension Setting {

  /// Tries to decode the JSON object to Setting object.
  public init(from decoder: Decoder) throws {
    let values: KeyedDecodingContainer<CodingKeys>? = try? decoder.container(keyedBy: CodingKeys.self)
    rankingRules = (try? values?.decodeIfPresent([String].self, forKey: .rankingRules)) ?? []
    searchableAttributes = (try? values?.decodeIfPresent([String].self, forKey: .searchableAttributes)) ?? ["*"]
    displayedAttributes = (try? values?.decodeIfPresent([String].self, forKey: .displayedAttributes)) ?? ["*"]
    stopWords = (try? values?.decodeIfPresent([String].self, forKey: .stopWords)) ?? []
    synonyms = (try? values?.decodeIfPresent([String: [String]].self, forKey: .synonyms)) ?? [:]
    distinctAttribute = try? values?.decodeIfPresent(String.self, forKey: .distinctAttribute)
    filterableAttributes = (try? values?.decodeIfPresent([String].self, forKey: .filterableAttributes)) ?? []
  }

}
