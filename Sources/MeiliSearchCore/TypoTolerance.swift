import Foundation

/**
 `TypoTolerance` settings provided by the user.
 */
public struct TypoTolerance: Codable, Equatable {
  // MARK: Properties

  /// Whether typo tolerance is enabled or not
  public let enabled: Bool?

  /// The minimum word size for accepting typos
  public let minWordSizeForTypos: MinWordSize?

  /// An array of words for which the typo tolerance feature is disabled
  public let disableOnWords: [String]?

  /// An array of attributes for which the typo tolerance feature is disabled
  public let disableOnAttributes: [String]?

  public struct MinWordSize: Codable, Equatable {
    /// The minimum word size for accepting 1 typo; must be between 0 and `twoTypos`
    public let oneTypo: Int?

    /// The minimum word size for accepting 2 typos; must be between `oneTypo` and 255
    public let twoTypos: Int?

    public init(
      oneTypo: Int? = nil,
      twoTypos: Int? = nil
    ) {
      self.oneTypo = oneTypo
      self.twoTypos = twoTypos
    }
  }

  public init(
    enabled: Bool? = nil,
    minWordSizeForTypos: TypoTolerance.MinWordSize? = nil,
    disableOnWords: [String]? = nil,
    disableOnAttributes: [String]? = nil
  ) {
    self.enabled = enabled
    self.minWordSizeForTypos = minWordSizeForTypos
    self.disableOnWords = disableOnWords
    self.disableOnAttributes = disableOnAttributes
  }
}
