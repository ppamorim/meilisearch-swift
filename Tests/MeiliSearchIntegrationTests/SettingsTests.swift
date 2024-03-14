@testable import MeiliSearch
@testable import MeiliSearchCore
import XCTest
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class SettingsTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private var session: URLSessionProtocol!
  private let uid: String = "books_test"

  private let defaultRankingRules: [String] = [
    "words",
    "typo",
    "proximity",
    "attribute",
    "sort",
    "exactness"
  ]
  private let defaultDistinctAttribute: String? = nil
  private let defaultDisplayedAttributes: [String] = ["*"]
  private let defaultSearchableAttributes: [String] = ["*"]
  private let defaultFilterableAttributes: [String] = []
  private let defaultSortableAttributes: [String] = []
  private let defaultNonSeparatorTokens: [String] = []
  private let defaultSeparatorTokens: [String] = []
  private let defaultDictionary: [String] = []
  private let defaultStopWords: [String] = []
  private let defaultSynonyms: [String: [String]] = [:]
  private let defaultPagination: Pagination = .init(maxTotalHits: 1000)
  private let defaultTypoTolerance: TypoTolerance = .init(
    enabled: true,
    minWordSizeForTypos: .init(oneTypo: 5, twoTypos: 9),
    disableOnWords: [],
    disableOnAttributes: []
  )
  private let defaultTypoToleranceResult: TypoToleranceResult = .init(
    enabled: true,
    minWordSizeForTypos: .init(oneTypo: 5, twoTypos: 9),
    disableOnWords: [],
    disableOnAttributes: []
  )
  private var defaultGlobalSettings: Setting?
  private var defaultGlobalReturnedSettings: SettingResult?

  // MARK: Setup

  override func setUpWithError() throws {
    try super.setUpWithError()

    session = URLSession(configuration: .ephemeral)
    client = try MeiliSearch(host: currentHost(), apiKey: "masterKey", session: session)
    index = self.client.index(self.uid)

    let createExpectation = XCTestExpectation(description: "Create Movies index")
    createGenericIndex(client: self.client, uid: self.uid) { result in
      switch result {
      case .success:
        createExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: TESTS_TIME_OUT)

    self.defaultGlobalSettings = Setting(
      rankingRules: self.defaultRankingRules,
      searchableAttributes: self.defaultSearchableAttributes,
      displayedAttributes: self.defaultDisplayedAttributes,
      stopWords: self.defaultStopWords,
      synonyms: self.defaultSynonyms,
      distinctAttribute: self.defaultDistinctAttribute,
      filterableAttributes: self.defaultFilterableAttributes,
      sortableAttributes: self.defaultFilterableAttributes,
      separatorTokens: self.defaultSeparatorTokens,
      nonSeparatorTokens: self.defaultNonSeparatorTokens,
      dictionary: self.defaultDictionary,
      pagination: self.defaultPagination,
      typoTolerance: self.defaultTypoTolerance
    )

    self.defaultGlobalReturnedSettings = SettingResult(
      rankingRules: self.defaultRankingRules,
      searchableAttributes: self.defaultSearchableAttributes,
      displayedAttributes: self.defaultDisplayedAttributes,
      stopWords: self.defaultStopWords,
      synonyms: self.defaultSynonyms,
      distinctAttribute: self.defaultDistinctAttribute,
      filterableAttributes: self.defaultFilterableAttributes,
      sortableAttributes: self.defaultSortableAttributes,
      separatorTokens: self.defaultSeparatorTokens,
      nonSeparatorTokens: self.defaultNonSeparatorTokens,
      dictionary: self.defaultDictionary,
      pagination: self.defaultPagination,
      typoTolerance: self.defaultTypoToleranceResult
    )
  }

  // MARK: Filterable Attributes

  func testGetFilterableAttributes() {
    let expectation = XCTestExpectation(description: "Get current filterable attributes")

    self.index.getFilterableAttributes { result in
      switch result {
      case .success(let attributes):
        XCTAssertEqual(self.defaultFilterableAttributes, attributes)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get settings")
        expectation.fulfill()
      }

    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateFilterableAttributes() {
    let expectation = XCTestExpectation(description: "Update settings for filterable attributes")
    let newFilterableAttributes: [String] = ["title"]

    self.index.updateFilterableAttributes(newFilterableAttributes) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newFilterableAttributes, details.filterableAttributes)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating filterable attributes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetFilterableAttributes() {
    let expectation = XCTestExpectation(description: "Reset settings for filterable attributes")

    self.index.resetFilterableAttributes { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting filterable attributes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // // MARK: Displayed attributes

  func testGetDisplayedAttributes() {
    let expectation = XCTestExpectation(description: "Get current displayed attributes")

    self.index.getDisplayedAttributes { result in
      switch result {
      case .success(let attributes):
        XCTAssertEqual(self.defaultDisplayedAttributes, attributes)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Could not get displayed attributes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateDisplayedAttributes() {
    let expectation = XCTestExpectation(description: "Update settings for displayed attributes")
    let newDisplayedAttributes: [String] = ["title"]

    self.index.updateDisplayedAttributes(newDisplayedAttributes) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newDisplayedAttributes, details.displayedAttributes)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update displayed attributes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetDisplayedAttributes() {
    let expectation = XCTestExpectation(description: "Reset settings for displayed attributes")

    self.index.resetDisplayedAttributes { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting displayed attributes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Distinct attributes

  func testGetDistinctAttribute() {
    let expectation = XCTestExpectation(description: "Get current distinct attribute")

    self.index.getDistinctAttribute { result in
      switch result {
      case .success(let attribute):
        XCTAssertEqual(self.defaultDistinctAttribute, attribute)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get distrinct attribute")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateDistinctAttribute() {
    let expectation = XCTestExpectation(description: "Update settings for distinct attribute")
    let newDistinctAttribute: String = "title"

    self.index.updateDistinctAttribute(newDistinctAttribute) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newDistinctAttribute, details.distinctAttribute)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating distinct attribute")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetDistinctAttributes() {
    let expectation = XCTestExpectation(description: "Reset settings for distinct attributes")

    self.index.resetDistinctAttribute { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
        }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting distinct attribute")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // // MARK: Ranking rules

  func testGetRankingRules() {
    let expectation = XCTestExpectation(description: "Get current ranking rules")

    self.index.getRankingRules { result in
      switch result {
      case .success(let rankingRules):
        XCTAssertEqual(self.defaultRankingRules, rankingRules)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get ranking rules")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateRankingRules() {
    let expectation = XCTestExpectation(description: "Update settings for ranking rules")

    let newRankingRules: [String] = [
      "words",
      "typo",
      "proximity"
    ]

    self.index.updateRankingRules(newRankingRules) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newRankingRules, details.rankingRules)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating ranking rules")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetRankingRules() {
    let expectation = XCTestExpectation(description: "Reset settings for ranking rules")

    self.index.resetRankingRules { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting ranking rules")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Searchable attributes

  func testGetSearchableAttributes() {
    let expectation = XCTestExpectation(description: "Get current searchable attributes")

    self.index.getSearchableAttributes { result in
      switch result {
      case .success(let searchableAttributes):
        XCTAssertEqual(self.defaultSearchableAttributes, searchableAttributes)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get searchable attributes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateSearchableAttributes() {
    let expectation = XCTestExpectation(description: "Update settings for searchable attributes")

    let newSearchableAttributes: [String] = [
      "id",
      "title"
    ]

    self.index.updateSearchableAttributes(newSearchableAttributes) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newSearchableAttributes, details.searchableAttributes)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating searchable attributes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetSearchableAttributes() {
    let expectation = XCTestExpectation(description: "Reset settings for searchable attributes")

    self.index.resetSearchableAttributes { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting searchable attributes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Typo Tolerance

  func testGetTypoTolerance() {
    let expectation = XCTestExpectation(description: "Get current typo tolerance")

    self.index.getTypoTolerance { result in
      switch result {
      case .success(let typoTolerance):
        XCTAssertEqual(self.defaultTypoToleranceResult, typoTolerance)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get typo tolerance")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateTypoTolerance() {
    let expectation = XCTestExpectation(description: "Update settings for typo tolerance")

    let newTypoTolerance: TypoTolerance = .init(
      minWordSizeForTypos: .init(
        oneTypo: 1,
        twoTypos: 2
      ),
      disableOnWords: ["to"],
      disableOnAttributes: ["genre"]
    )

    self.index.updateTypoTolerance(newTypoTolerance) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newTypoTolerance, details.typoTolerance)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating typo tolerance")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetTypoTolerance() {
    let expectation = XCTestExpectation(description: "Reset settings for typo tolerance")

    self.index.resetTypoTolerance { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting typo tolerance")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Separator Tokens

  func testGetSeparatorTokens() {
    let expectation = XCTestExpectation(description: "Get current Separator Tokens")

    self.index.getSeparatorTokens { result in
      switch result {
      case .success(let separatorTokens):
        XCTAssertEqual(self.defaultSeparatorTokens, separatorTokens)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get Separator Tokens")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateSeparatorTokens() {
    let expectation = XCTestExpectation(description: "Update settings for separator tokens")

    let newSeparatorTokens: [String] = [
      "&",
      "</br>",
      "@"
    ]

    self.index.updateSeparatorTokens(newSeparatorTokens) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newSeparatorTokens, details.separatorTokens)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating separator tokens")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetSeparatorTokens() {
    let expectation = XCTestExpectation(description: "Reset settings for separator tokens")

    self.index.resetSeparatorTokens { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting separator tokens")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Non Separator Tokens

  func testGetNonSeparatorTokens() {
    let expectation = XCTestExpectation(description: "Get current non separator tokens")

    self.index.getNonSeparatorTokens { result in
      switch result {
      case .success(let nonSeparatorTokens):
        XCTAssertEqual(self.defaultNonSeparatorTokens, nonSeparatorTokens)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get non separator tokens")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateNonSeparatorTokens() {
    let expectation = XCTestExpectation(description: "Update settings for non separator tokens")

    let newNonSeparatorTokens: [String] = [
      "#",
      "-",
      "_"
    ]

    self.index.updateNonSeparatorTokens(newNonSeparatorTokens) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newNonSeparatorTokens, details.nonSeparatorTokens)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating non separator tokens")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetNonSeparatorTokens() {
    let expectation = XCTestExpectation(description: "Reset settings for searchable attributes")

    self.index.resetSearchableAttributes { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting searchable attributes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Dictionary

  func testGetDictionary() {
    let expectation = XCTestExpectation(description: "Get current dictionary")

    self.index.getDictionary { result in
      switch result {
      case .success(let dictionary):
        XCTAssertEqual(self.defaultDictionary, dictionary)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get dictionary")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateDictionary() {
    let expectation = XCTestExpectation(description: "Update settings for dictionary")

    let newDictionary: [String] = [
      "J.K",
      "Dr.",
      "G/Box"
    ]

    self.index.updateDictionary(newDictionary) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newDictionary.sorted(), details.dictionary?.sorted())
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating dictionary")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetDictionary() {
    let expectation = XCTestExpectation(description: "Reset settings for dictionary")

    self.index.resetDictionary { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting dictionary")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Pagination

  func testGetPagination() {
    let expectation = XCTestExpectation(description: "Get current pagination")

    self.index.getPaginationSettings { result in
      switch result {
      case .success(let pagination):
        XCTAssertEqual(self.defaultPagination, pagination)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get searchable attributes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdatePagination() {
    let expectation = XCTestExpectation(description: "Update settings for pagination")

    let newPaginationSettings: Pagination = .init(maxTotalHits: 5)

    self.index.updatePaginationSettings(newPaginationSettings) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newPaginationSettings, details.pagination)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating pagination")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetPagination() {
    let expectation = XCTestExpectation(description: "Reset settings for pagination")

    self.index.resetPaginationSettings { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting pagination")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Stop words

  func testGetStopWords() {
    let expectation = XCTestExpectation(description: "Get current stop words")

    self.index.getStopWords { result in
      switch result {
      case .success(let stopWords):
        XCTAssertEqual(self.defaultStopWords, stopWords)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get stop words")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateStopWords() {
    let expectation = XCTestExpectation(description: "Update stop words")

    let newStopWords: [String] = ["the"]

    self.index.updateStopWords(newStopWords) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newStopWords, details.stopWords)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating stop words")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateStopWordsWithEmptyArray() {
    let expectation = XCTestExpectation(description: "Update stop words")
    let emptyStopWords: [String]? = [String]()

    self.index.updateStopWords(emptyStopWords) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(emptyStopWords, details.stopWords)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating stop words")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateStopWordsWithNullValue() {
    let expectation = XCTestExpectation(description: "Update stop words")
    let nilStopWords: [String]? = nil

    self.index.updateStopWords(nilStopWords) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(nilStopWords, details.stopWords)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating stop words")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetStopWords() {
    let expectation = XCTestExpectation(description: "Reset stop words")

    self.index.resetStopWords { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting reset stop words")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Synonyms

  func testGetSynonyms() {
    let expectation = XCTestExpectation(description: "Get current synonyms")

    self.index.getSynonyms { result in
      switch result {
      case .success(let synonyms):
        XCTAssertEqual(self.defaultSynonyms, synonyms)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get synonyms")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateSynonyms() {
    let expectation = XCTestExpectation(description: "Update synonyms")

    let newSynonyms: [String: [String]] = [
      "wolverine": ["xmen", "logan"],
      "logan": ["wolverine", "xmen"],
      "wow": ["world of warcraft"],
      "rct": ["rollercoaster tycoon"]
    ]

    self.index.updateSynonyms(newSynonyms) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newSynonyms, details.synonyms)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating stop words")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateSynonymsEmptyString() {
    let expectation = XCTestExpectation(description: "Update synonyms")
    let newSynonyms = [String: [String]]()

    self.index.updateSynonyms(newSynonyms) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newSynonyms, details.synonyms)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating stop words")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateSynonymsNil() {
    let expectation = XCTestExpectation(description: "Update synonyms")

    let newSynonyms: [String: [String]]? = nil

    self.index.updateSynonyms(newSynonyms) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(newSynonyms, details.synonyms)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating stop words")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetSynonyms() {
    let expectation = XCTestExpectation(description: "Reset synonyms")

    self.index.resetSynonyms { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting synonyms")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Global Settings

  func testGetSettings() {
    let expectation = XCTestExpectation(description: "Get current settings")

    self.index.getSettings { result in
      switch result {
      case .success(let settings):
        XCTAssertEqual(self.defaultGlobalReturnedSettings, settings)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get settings")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateSettings() {
    let newSettings = Setting(
      rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"],
      searchableAttributes: ["id", "title"],
      stopWords: ["a"]
    )

    let overrideSettings = Setting(
      rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"]
    )

    let expectedSettingResult = SettingResult(
      rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"],
      searchableAttributes: ["id", "title"],
      displayedAttributes: ["*"],
      stopWords: ["a"],
      synonyms: [:],
      distinctAttribute: nil,
      filterableAttributes: [],
      sortableAttributes: ["title"],
      separatorTokens: [],
      nonSeparatorTokens: [],
      dictionary: [],
      pagination: .init(maxTotalHits: 1000),
      typoTolerance: defaultTypoToleranceResult
    )

    let expectation = XCTestExpectation(description: "Update settings")
    self.index.updateSettings(newSettings) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(expectedSettingResult.rankingRules, details.rankingRules)
              XCTAssertEqual(expectedSettingResult.searchableAttributes, details.searchableAttributes)
              XCTAssertEqual(expectedSettingResult.stopWords, details.stopWords)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating settings")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)

    let overrideSettingsExpectation = XCTestExpectation(description: "Update settings")

    // Test if absents settings are sent to Meilisearch with a nil value.
    self.index.updateSettings(overrideSettings) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if case .settingsUpdate(let details) = task.details {
              XCTAssertEqual(expectedSettingResult.rankingRules, details.rankingRules)
            } else {
              XCTFail("settingsUpdate details should be set by task")
            }
            overrideSettingsExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            overrideSettingsExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating settings")
        overrideSettingsExpectation.fulfill()
      }
    }
    self.wait(for: [overrideSettingsExpectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateSettingsWithSynonymsAndStopWordsNil() {
    let expectation = XCTestExpectation(description: "Update settings")

    let newSettings = Setting(
      rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"],
      searchableAttributes: ["id", "title"],
      displayedAttributes: ["*"],
      stopWords: nil,
      synonyms: nil,
      distinctAttribute: nil,
      filterableAttributes: ["title"],
      sortableAttributes: ["title"],
      separatorTokens: ["&"],
      nonSeparatorTokens: ["#"],
      dictionary: ["J.K"],
      pagination: .init(maxTotalHits: 500),
      typoTolerance: nil
    )

    let expectedSettingResult = SettingResult(
      rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"],
      searchableAttributes: ["id", "title"],
      displayedAttributes: ["*"],
      stopWords: [],
      synonyms: [:],
      distinctAttribute: nil,
      filterableAttributes: ["title"],
      sortableAttributes: ["title"],
      separatorTokens: ["&"],
      nonSeparatorTokens: ["#"],
      dictionary: ["J.K"],
      pagination: .init(maxTotalHits: 500),
      typoTolerance: defaultTypoToleranceResult
    )

    self.index.updateSettings(newSettings) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
        switch result {
        case .success(let task):
          XCTAssertEqual("settingsUpdate", task.type.description)
          XCTAssertEqual(Task.Status.succeeded, task.status)
          if case .settingsUpdate(let details) = task.details {
            XCTAssertEqual(expectedSettingResult.rankingRules, details.rankingRules)
            XCTAssertEqual(expectedSettingResult.searchableAttributes, details.searchableAttributes)
            XCTAssertEqual(expectedSettingResult.displayedAttributes, details.displayedAttributes)
            XCTAssertEqual(expectedSettingResult.distinctAttribute, details.distinctAttribute)
            XCTAssertEqual(expectedSettingResult.filterableAttributes, details.filterableAttributes)
            XCTAssertEqual(expectedSettingResult.sortableAttributes, details.sortableAttributes)
            XCTAssertEqual(expectedSettingResult.separatorTokens, details.separatorTokens)
            XCTAssertEqual(expectedSettingResult.nonSeparatorTokens, details.nonSeparatorTokens)
            XCTAssertEqual(expectedSettingResult.dictionary, details.dictionary)
            XCTAssertEqual(expectedSettingResult.pagination.maxTotalHits, details.pagination?.maxTotalHits)
          } else {
            XCTFail("settingsUpdate details should be set by task")
          }
          expectation.fulfill()
        case .failure(let error):
          dump(error)
          XCTFail("Failed to wait for task")
          expectation.fulfill()
        }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed updating settings")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetSettings() {
    let expectation = XCTestExpectation(description: "Reset settings")

    self.index.resetSettings { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("settingsUpdate", task.type.description)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed reseting settings")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }
}
