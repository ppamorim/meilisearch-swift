@testable import MeiliSearch
import XCTest

// swiftlint:disable force_unwrapping
// swiftlint:disable force_cast
// swiftlint:disable force_try
class SettingsTests: XCTestCase {

  private var client: MeiliSearch!
  private let session = MockURLSession()

  private let json = """
    {
      "rankingRules": [
        "words",
        "typo",
        "proximity",
        "attribute",
        "exactness",
        "desc(release_date)"
      ],
      "searchableAttributes": ["title", "description", "uid"],
      "displayedAttributes": [
        "title",
        "description",
        "release_date",
        "rank",
        "poster"
      ],
      "filterableAttributes": [],
      "stopWords": [],
      "synonyms": {
        "wolverine": ["xmen", "logan"],
        "logan": ["wolverine", "xmen"]
      }
    }
    """

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
  }

  // MARK: Settings

  func testShouldInstantiateFromEmptyData() {
    let stubSetting: Setting = buildStubSetting(from: "{}")
    XCTAssertTrue(stubSetting.rankingRules.isEmpty)
    XCTAssertEqual(stubSetting.searchableAttributes, ["*"])
    XCTAssertEqual(stubSetting.displayedAttributes, ["*"])
    XCTAssertEqual(stubSetting.stopWords, [])
    XCTAssertEqual(stubSetting.synonyms, [String: [String]]())
  }

  func testGetSetting() {

    // Prepare the mock server

    let stubSetting: SettingResult = buildStubSettingResult(from: json)

    session.pushData(json)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Get settings")

    self.client.getSetting(UID: UID) { result in
      switch result {
      case .success(let setting):
        XCTAssertEqual(stubSetting, setting)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get settings")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testUpdateSetting() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let jsonData = jsonString.data(using: .utf8)!
    let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"
    let setting: Setting = buildStubSetting(from: json)

    let expectation = XCTestExpectation(description: "Update settings")

    self.client.updateSetting(UID: UID, setting) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to update settings")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testResetSetting() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let data: Data = jsonString.data(using: .utf8)!
    let stubUpdate: Update = try! decoder.decode(Update.self, from: data)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Reset settings")

    self.client.resetSetting(UID: UID) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to reset settings")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  // MARK: Synonyms

  func testGetSynonyms() {

    // Prepare the mock server

    let jsonString = """
      {
        "wolverine": ["xmen", "logan"],
        "logan": ["wolverine", "xmen"],
        "wow": ["world of warcraft"]
      }
      """

    let jsonData = jsonString.data(using: .utf8)!
    let stubSynonyms: [String: [String]] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String: [String]]

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Get synonyms")

    self.client.getSynonyms(UID: UID) { result in
      switch result {
      case .success(let synonyms):
        XCTAssertEqual(stubSynonyms, synonyms)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get synonyms")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testUpdateSynonyms() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let json = """
      {
        "wolverine": ["xmen", "logan"],
        "logan": ["wolverine", "xmen"],
        "wow": ["world of warcraft"]
      }
      """

    let jsonData = json.data(using: .utf8)!
    let synonyms: [String: [String]] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String: [String]]

    let expectation = XCTestExpectation(description: "Update synonyms")

    self.client.updateSynonyms(UID: UID, synonyms) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to update synonyms")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testResetSynonyms() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Reset synonyms")

    self.client.resetSynonyms(UID: UID) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to reset synonyms")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  // MARK: Stop words

  func testGetStopWords() {

    // Prepare the mock server

    let jsonString = """
      ["of", "the", "to"]
      """

    let jsonData = jsonString.data(using: .utf8)!
    let stubStopWords: [String] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Get stop-words")

    self.client.getStopWords(UID: UID) { result in
      switch result {
      case .success(let stopWords):
        XCTAssertEqual(stubStopWords, stopWords)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get stop-words")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testUpdateStopWords() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let json = """
      ["of", "the", "to"]
      """

    let stopWords: [String] = try! JSONSerialization.jsonObject(
      with: json.data(using: .utf8)!, options: []) as! [String]

    let expectation = XCTestExpectation(description: "Update stop-words")

    self.client.updateStopWords(UID: UID, stopWords) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to update stop-words")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testResetStopWords() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Reset stop-words")

    self.client.resetStopWords(UID: UID) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to reset stop-words")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  // MARK: Ranking rules

  func testGetRankingRules() {

    // Prepare the mock server

    let jsonString = """
      [
        "words",
        "typo",
        "proximity",
        "attribute",
        "exactness",
        "desc(release_date)"
      ]
      """

    let jsonData = jsonString.data(using: .utf8)!
    let stubRakingRules: [String] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Get ranking rules")

    self.client.getRankingRules(UID: UID) { result in
      switch result {
      case .success(let rankingRules):
        XCTAssertEqual(stubRakingRules, rankingRules)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get ranking rules")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testUpdateRankingRules() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let json = """
      ["of", "the", "to"]
      """

    let stopWords: [String] = try! JSONSerialization.jsonObject(
      with: json.data(using: .utf8)!, options: []) as! [String]

    let expectation = XCTestExpectation(description: "Update ranking rules")

    self.client.updateRankingRules(UID: UID, stopWords) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to update ranking rules")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testResetRankingRules() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Reset ranking rules")

    self.client.resetRankingRules(UID: UID) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to reset ranking rules")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  // MARK: Distinct Attribute

  func testGetDistinctAttribute() {

    // Prepare the mock server

    let stubDistinctAttribute: String = """
      "movie_id"
      """

    session.pushData(stubDistinctAttribute)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Get distinct attribute")

    self.client.getDistinctAttribute(UID: UID) { result in
      switch result {
      case .success(let distinctAttribute):
        XCTAssertEqual("movie_id", distinctAttribute!)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get distinct attribute")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testUpdateDistinctAttribute() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"
    let distinctAttribute = "movie_id"

    let expectation = XCTestExpectation(description: "Update distinct attribute")

    self.client.updateDistinctAttribute(UID: UID, distinctAttribute) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to update distinct attribute")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testResetDistinctAttribute() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Reset distinct attribute")

    self.client.resetDistinctAttribute(UID: UID) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to reset distinct attribute")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  // MARK: Searchable Attribute

  func testGetSearchableAttributes() {

    // Prepare the mock server

    let jsonString = """
      ["title", "description", "uid"]
      """

    let jsonData = jsonString.data(using: .utf8)!
    let stubSearchableAttribute: [String] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Get searchable attribute")

    self.client.getSearchableAttributes(UID: UID) { result in
      switch result {
      case .success(let searchableAttribute):
        XCTAssertEqual(stubSearchableAttribute, searchableAttribute)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get searchable attribute")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testUpdateSearchableAttributes() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let json = """
      ["title", "description", "uid"]
      """

    let jsonData = json.data(using: .utf8)!
    let searchableAttribute: [String] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]

    let expectation = XCTestExpectation(description: "Update searchable attribute")

    self.client.updateSearchableAttributes(UID: UID, searchableAttribute) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to update searchable attribute")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testResetSearchableAttributes() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Reset searchable attribute")

    self.client.resetSearchableAttributes(UID: UID) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to reset searchable attribute")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  // MARK: Displayed Attributes

  func testGetDisplayedAttributes() {

    // Prepare the mock server

    let jsonString = """
      ["title", "description", "release_date", "rank", "poster"]
      """

    let jsonData = jsonString.data(using: .utf8)!
    let stubDisplayedAttributes: [String] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Get displayed attribute")

    self.client.getDisplayedAttributes(UID: UID) { result in
      switch result {
      case .success(let displayedAttributes):
        XCTAssertEqual(stubDisplayedAttributes, displayedAttributes)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get displayed attribute")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testUpdateDisplayedAttributes() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let json = """
      ["title", "description", "release_date", "rank", "poster"]
      """

    let jsonData = json.data(using: .utf8)!
    let displayedAttributes: [String] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]

    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.client.updateDisplayedAttributes(UID: UID, displayedAttributes) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testResetDisplayedAttributes() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Reset displayed attribute")

    self.client.resetDisplayedAttributes(UID: UID) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to reset displayed attribute")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  // MARK: Filterable Attributes

  func testGetFilterableAttributes() {

    // Prepare the mock server

    let jsonString = """
      ["genre", "director"]
      """

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Get displayed attribute")

    self.client.getFilterableAttributes(UID: UID) { result in
      switch result {
      case .success(let filterableAttributes):
        XCTAssertFalse(filterableAttributes.isEmpty)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get displayed attribute")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testUpdateFilterableAttributes() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"
    let attributes: [String] = ["genre", "director"]

    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.client.updateFilterableAttributes(UID: UID, attributes) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  func testResetFilterableAttributes() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":1}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let UID: String = "movies"

    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.client.resetFilterableAttributes(UID: UID) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)

  }

  private func buildStubSetting(from json: String) -> Setting {
    let data = json.data(using: .utf8)!
    let decoder: JSONDecoder = JSONDecoder()
    return try! decoder.decode(Setting.self, from: data)
  }

  private func buildStubSettingResult(from json: String) -> SettingResult {
    let data = json.data(using: .utf8)!
    let decoder: JSONDecoder = JSONDecoder()
    return try! decoder.decode(SettingResult.self, from: data)
  }

  static var allTests = [
    ("testShouldInstantiateFromEmptyData", testShouldInstantiateFromEmptyData),
    ("testGetSetting", testGetSetting),
    ("testUpdateSetting", testUpdateSetting),
    ("testResetSetting", testResetSetting),
    ("testGetSynonyms", testGetSynonyms),
    ("testUpdateSynonyms", testUpdateSynonyms),
    ("testResetSynonyms", testResetSynonyms),
    ("testGetStopWords", testGetStopWords),
    ("testUpdateStopWords", testUpdateStopWords),
    ("testResetStopWords", testResetStopWords),
    ("testGetRankingRules", testGetRankingRules),
    ("testUpdateRankingRules", testUpdateRankingRules),
    ("testResetRankingRules", testResetRankingRules),
    ("testGetDistinctAttribute", testGetDistinctAttribute),
    ("testUpdateDistinctAttribute", testUpdateDistinctAttribute),
    ("testResetDistinctAttribute", testResetDistinctAttribute),
    ("testGetSearchableAttributes", testGetSearchableAttributes),
    ("testUpdateSearchableAttributes", testUpdateSearchableAttributes),
    ("testResetSearchableAttributes", testResetSearchableAttributes),
    ("testGetDisplayedAttributes", testGetDisplayedAttributes),
    ("testUpdateDisplayedAttributes", testUpdateDisplayedAttributes),
    ("testResetDisplayedAttributes", testResetDisplayedAttributes),
    ("testGetFilterableAttributes", testGetFilterableAttributes),
    ("testUpdateFilterableAttributes", testUpdateFilterableAttributes),
    ("testResetFilterableAttributes", testResetFilterableAttributes)
  ]

}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_cast
// swiftlint:enable force_try
