@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest

class SettingsTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private var uid: String = "movies_test"
  private let session = MockURLSession()

  private let json = """
    {
      "rankingRules": [
        "words",
        "typo",
        "proximity",
        "attribute",
        "sort",
        "exactness",
        "release_date:desc"
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
      "sortableAttributes": [],
      "stopWords": [],
      "separatorTokens": [],
      "nonSeparatorTokens": [],
      "dictionary": [],
      "pagination": {
        "maxTotalHits": 1000
      },
      "synonyms": {
        "wolverine": ["xmen", "logan"],
        "logan": ["wolverine", "xmen"]
      },
      "typoTolerance": {
        "enabled": true,
        "minWordSizeForTypos": {
          "oneTypo": 5,
          "twoTypos": 9
        },
        "disableOnWords": [],
        "disableOnAttributes": []
      }
    }
    """

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = self.client.index(self.uid)
  }

  // MARK: Settings

  func testGetSettings() async throws {
    // Prepare the mock server
    let stubSetting: SettingResult = try buildStubSettingResult(from: json)
    session.pushData(json)

    // Start the test with the mocked server
    let setting = try await self.index.getSettings()
    XCTAssertEqual(stubSetting, setting)
  }

  func testUpdateSettings() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let jsonData = Data(jsonString.utf8)
    let stubTask: TaskInfo = try decoder.decode(TaskInfo.self, from: jsonData)

    session.pushData(jsonString)
    let setting: Setting = try buildStubSetting(from: json)

    // Start the test with the mocked server
    let update = try await self.index.updateSettings(setting)
    XCTAssertEqual(stubTask, update)
  }

  func testResetSettings() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let data: Data = Data(jsonString.utf8)
    let stubTask: TaskInfo = try decoder.decode(TaskInfo.self, from: data)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let update = try await self.index.resetSettings()
    XCTAssertEqual(stubTask, update)
  }

  // MARK: Synonyms

  func testGetSynonyms() async throws {
    let jsonString = """
      {
        "wolverine": ["xmen", "logan"],
        "logan": ["wolverine", "xmen"],
        "wow": ["world of warcraft"]
      }
      """

    // Prepare the mock server
    let jsonData = Data(jsonString.utf8)
    let stubSynonyms: [String: [String]] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String: [String]]

    session.pushData(jsonString)

    // Start the test with the mocked server
    let synonyms = try await self.index.getSynonyms()
    XCTAssertEqual(stubSynonyms, synonyms)
  }

  func testUpdateSynonyms() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)
    let json = """
      {
        "wolverine": ["xmen", "logan"],
        "logan": ["wolverine", "xmen"],
        "wow": ["world of warcraft"]
      }
      """
    let jsonData = Data(json.utf8)
    let synonyms: [String: [String]] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String: [String]]

    // Start the test with the mocked server
    let update = try await self.index.updateSynonyms(synonyms)
    XCTAssertEqual(stubTask, update)
  }

  func testResetSynonyms() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)

    // Start the test with the mocked server
    let update = try await self.index.resetSynonyms()
    XCTAssertEqual(stubTask, update)
  }

  // MARK: Stop words

  func testGetStopWords() async throws {
    let jsonString = """
      ["of", "the", "to"]
      """

    // Prepare the mock server
    let jsonData = Data(jsonString.utf8)
    let stubStopWords: [String] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]
    session.pushData(jsonString)

    // Start the test with the mocked server
    let stopWords = try await self.index.getStopWords()
    XCTAssertEqual(stubStopWords, stopWords)
  }

  func testUpdateStopWords() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)
    let json = """
      ["of", "the", "to"]
      """

    let stopWords: [String] = try JSONSerialization.jsonObject(
      with: Data(json.utf8), options: []) as! [String]

    // Start the test with the mocked server
    let update = try await self.index.updateStopWords(stopWords)
    XCTAssertEqual(update, stubTask)
  }

  func testResetStopWords() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)

    // Start the test with the mocked server
    let update = try await self.index.resetStopWords()
    XCTAssertEqual(stubTask, update)
  }

  // MARK: Ranking rules

  func testGetRankingRules() async throws {
    let jsonString = """
      [
        "words",
        "typo",
        "proximity",
        "attribute",
        "sort",
        "exactness",
        "release_date:desc"
      ]
      """

    // Prepare the mock server
    let jsonData = Data(jsonString.utf8)
    let stubRankingRules: [String] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]
    session.pushData(jsonString)

    // Start the test with the mocked server
    let rankingRules = try await self.index.getRankingRules()
    XCTAssertEqual(stubRankingRules, rankingRules)
  }

  func testUpdateRankingRules() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)
    let json = """
      ["of", "the", "to"]
      """
    let stopWords: [String] = try JSONSerialization.jsonObject(
      with: Data(json.utf8), options: []) as! [String]

    // Start the test with the mocked server
    let update = try await self.index.updateRankingRules(stopWords)
    XCTAssertEqual(stubTask, update)
  }

  func testResetRankingRules() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)

    // Start the test with the mocked server
    let update = try await self.index.resetRankingRules()
    XCTAssertEqual(stubTask, update)
  }

  // MARK: Distinct Attribute

  func testGetDistinctAttribute() async throws {
    let stubDistinctAttribute: String = """
      "movie_id"
      """

    // Prepare the mock server
    session.pushData(stubDistinctAttribute)

    // Start the test with the mocked server
    let distinctAttribute = try await self.index.getDistinctAttribute()
    XCTAssertEqual("movie_id", distinctAttribute)
  }

  func testUpdateDistinctAttribute() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)
    let distinctAttribute = "movie_id"

    // Start the test with the mocked server
    let update = try await self.index.updateDistinctAttribute(distinctAttribute)
    XCTAssertEqual(stubTask, update)
  }

  func testResetDistinctAttribute() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)

    // Start the test with the mocked server
    let update = try await self.index.resetDistinctAttribute()
    XCTAssertEqual(stubTask, update)
  }

  // MARK: Searchable Attribute

  func testGetSearchableAttributes() async throws {
    let jsonString = """
      ["title", "description", "uid"]
      """

    // Prepare the mock server
    let jsonData = Data(jsonString.utf8)
    let stubSearchableAttribute: [String] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]
    session.pushData(jsonString)

    // Start the test with the mocked server
    let searchableAttribute = try await self.index.getSearchableAttributes()
    XCTAssertEqual(stubSearchableAttribute, searchableAttribute)
  }

  func testUpdateSearchableAttributes() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)

    let json = """
      ["title", "description", "uid"]
      """
    let jsonData = Data(json.utf8)
    let searchableAttribute: [String] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]

    // Start the test with the mocked server
    let update = try await self.index.updateSearchableAttributes(searchableAttribute)
    XCTAssertEqual(stubTask, update)
  }

  func testResetSearchableAttributes() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)

    // Start the test with the mocked server
    let update = try await self.index.resetSearchableAttributes()
    XCTAssertEqual(stubTask, update)
  }

  // MARK: Displayed Attributes

  func testGetDisplayedAttributes() async throws {
    let jsonString = """
      ["title", "description", "release_date", "rank", "poster"]
      """

    // Prepare the mock server
    let jsonData = Data(jsonString.utf8)
    let stubDisplayedAttributes: [String] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]
    session.pushData(jsonString)

    // Start the test with the mocked server
    let displayedAttributes = try await self.index.getDisplayedAttributes()
    XCTAssertEqual(stubDisplayedAttributes, displayedAttributes)
  }

  func testUpdateDisplayedAttributes() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)

    let json = """
      ["title", "description", "release_date", "rank", "poster"]
      """

    let jsonData = Data(json.utf8)
    let displayedAttributes: [String] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]

    // Start the test with the mocked server
    let update = try await self.index.updateDisplayedAttributes(displayedAttributes)
    XCTAssertEqual(stubTask, update)
  }

  func testResetDisplayedAttributes() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)

    // Start the test with the mocked server
    let update = try await self.index.resetDisplayedAttributes()
    XCTAssertEqual(stubTask, update)
  }

  // MARK: Filterable Attributes

  func testGetFilterableAttributes() async throws {
    let jsonString = """
      ["genre", "director"]
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let filterableAttributes = try await self.index.getFilterableAttributes()
    XCTAssertFalse(filterableAttributes.isEmpty)
  }

  func testUpdateFilterableAttributes() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)
    let attributes: [String] = ["genre", "director"]

    // Start the test with the mocked server
    let update = try await self.index.updateFilterableAttributes(attributes)
    XCTAssertEqual(stubTask, update)
  }

  func testResetFilterableAttributes() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)

    // Start the test with the mocked server
    let update = try await self.index.resetFilterableAttributes()
    XCTAssertEqual(stubTask, update)
  }

  // MARK: Filterable Attributes

  func testGetSortableAttributes() async throws {
    let jsonString = """
      ["genre", "director"]
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let sortableAttributes = try await self.index.getSortableAttributes()
    XCTAssertFalse(sortableAttributes.isEmpty)
  }

  func testUpdateSortableAttributes() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)
    let attributes: [String] = ["genre", "director"]

    // Start the test with the mocked server
    let update = try await self.index.updateSortableAttributes(attributes)
    XCTAssertEqual(stubTask, update)
  }

  func testResetSortableAttributes() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)

    // Start the test with the mocked server
    let update = try await self.index.resetSortableAttributes()
    XCTAssertEqual(stubTask, update)
  }

  // MARK: Typo Tolerance

  func testGetTypoTolerance() async throws {
    let jsonString = """
      {"enabled":true,"minWordSizeForTypos":{"oneTypo":3,"twoTypos":7},"disableOnWords":["of", "the"],"disableOnAttributes":["genre"]}
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let typoTolerance = try await self.index.getTypoTolerance()
    XCTAssertTrue(typoTolerance.enabled)
    XCTAssertEqual(typoTolerance.minWordSizeForTypos.oneTypo, 3)
    XCTAssertEqual(typoTolerance.minWordSizeForTypos.twoTypos, 7)
    XCTAssertFalse(typoTolerance.disableOnWords.isEmpty)
    XCTAssertFalse(typoTolerance.disableOnAttributes.isEmpty)
  }

  func testUpdateTypoTolerance() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(TaskInfo.self, from: Data(jsonString.utf8))

    session.pushData(jsonString)
    let typoTolerance: TypoTolerance = .init(enabled: false)

    // Start the test with the mocked server
    let update = try await self.index.updateTypoTolerance(typoTolerance)
    XCTAssertEqual(stubTask, update)
  }

  func testResetTypoTolerance() async throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(TaskInfo.self, from: Data(jsonString.utf8))
    session.pushData(jsonString)

    // Start the test with the mocked server
    let update = try await self.index.resetTypoTolerance()
    XCTAssertEqual(stubTask, update)
  }

  private func buildStubSetting(from json: String) throws -> Setting {
    let data = Data(json.utf8)
    let decoder = Constants.customJSONDecoder
    return try decoder.decode(Setting.self, from: data)
  }

  private func buildStubSettingResult(from json: String) throws -> SettingResult {
    let data = Data(json.utf8)
    let decoder = Constants.customJSONDecoder
    return try decoder.decode(SettingResult.self, from: data)
  }
}
