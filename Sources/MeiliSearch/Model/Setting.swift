import Foundation

import Foundation

/**
 Each instance of MeiliSearch has three keys: a master, a private, and a public.
 Each key has a given set of permissions on the API routes.
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
    public let stopWords: [String]

    /// List of synonyms and its values for a given `Index`.
    public let synonyms: [String: [String]]

    /// Optional distinct attribute set for a given `Index`.
    public let distinctAttribute: String?

    /// List of attributes used for the faceting
    public let attributesForFaceting: [String]

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
        attributesForFaceting = (try? values?.decodeIfPresent([String].self, forKey: .attributesForFaceting)) ?? []
    }

}

public enum Action<T> {
  case update(_ t: T)
  case keep
  func value() -> T {
    switch self {
    case .update(let t):
      return t
    default:
      fatalError()
    }
  }
}

/**
 Each instance of MeiliSearch has three keys: a master, a private, and a public.
 Each key has a given set of permissions on the API routes.
 */
public struct UpdateSetting: Encodable {

    // MARK: Properties

    /// List of ranking rules for a given `Index`.
    public let rankingRules: Action<[String]>

    /// List of searchable attributes for a given `Index`.
    public let searchableAttributes: Action<[String]>

    /// List of displayed attributes for a given `Index`.
    public let displayedAttributes: Action<[String]>

    /// List of stop-words for a given `Index`.
    public let stopWords: Action<[String]>

    /// List of synonyms and its values for a given `Index`.
    public let synonyms: Action<[String: [String]]>

    /// Optional distinct attribute set for a given `Index`.
    public let distinctAttribute: Action<String?>

    /// List of attributes used for the faceting
    public let attributesForFaceting: Action<[String]>
  
    enum CodingKeys: String, CodingKey {
        case rankingRules, searchableAttributes, displayedAttributes, stopWords, synonyms, distinctAttribute, attributesForFaceting
    }
  
    public init(
        rankingRules: Action<[String]> = .keep,
        searchableAttributes: Action<[String]> = .keep,
        displayedAttributes: Action<[String]> = .keep,
        stopWords: Action<[String]> = .keep,
        synonyms: Action<[String: [String]]> = .keep,
        distinctAttribute: Action<String?> = .keep,
        attributesForFaceting: Action<[String]> = .keep) {
        self.rankingRules = rankingRules
        self.searchableAttributes = searchableAttributes
        self.displayedAttributes = displayedAttributes
        self.stopWords = stopWords
        self.synonyms = synonyms
        self.distinctAttribute = distinctAttribute
        self.attributesForFaceting = attributesForFaceting
    }
  
    public init(setting: Setting) {
        self.rankingRules = .update(setting.rankingRules)
        self.searchableAttributes = .update(setting.searchableAttributes)
        self.displayedAttributes = .update(setting.displayedAttributes)
        self.stopWords = .update(setting.stopWords)
        self.synonyms = .update(setting.synonyms)
        self.distinctAttribute = .update(setting.distinctAttribute)
        self.attributesForFaceting = .update(setting.attributesForFaceting)
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      if case let .update(rankingRules) = rankingRules {
        try container.encode(rankingRules, forKey: .rankingRules)
      }
      if case let .update(searchableAttributes) = searchableAttributes {
        try container.encode(searchableAttributes, forKey: .searchableAttributes)
      }
      if case let .update(displayedAttributes) = displayedAttributes {
        try container.encode(displayedAttributes, forKey: .displayedAttributes)
      }
      if case let .update(stopWords) = stopWords {
        try container.encode(stopWords, forKey: .stopWords)
      }
      if case let .update(synonyms) = synonyms {
        try container.encode(synonyms, forKey: .synonyms)
      }
      if case let .update(distinctAttribute) = distinctAttribute {
        try container.encode(distinctAttribute, forKey: .distinctAttribute)
      }
      if case let .update(attributesForFaceting) = attributesForFaceting {
        try container.encode(attributesForFaceting, forKey: .attributesForFaceting)
      }
    }
  
}
