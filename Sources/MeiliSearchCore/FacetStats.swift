import Foundation

/**
 `FacetStats` instance represents the minimum and maximum values received for a provided facet
 */
public struct FacetStats: Codable, Equatable {
  // MARK: Properties

  /// The minimum value found in the given facet
  public let min: Double

  /// The maximum value found in the given facet
  public let max: Double
}
