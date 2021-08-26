<p align="center">
  <img src="https://github.com/meilisearch/meilisearch-swift/blob/main/assets/logo.svg" alt="MeiliSearch-Swift" width="200" height="200" />
</p>

<h1 align="center">MeiliSearch-Swift</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/MeiliSearch">MeiliSearch</a> |
  <a href="https://meilisearch.github.io/meilisearch-swift/">Documentation</a> |
  <a href="https://slack.meilisearch.com">Slack</a> |
  <a href="https://roadmap.meilisearch.com/tabs/1-under-consideration">Roadmap</a> |
  <a href="https://www.meilisearch.com">Website</a> |
  <a href="https://docs.meilisearch.com/faq">FAQ</a>
</h4>

<p align="center">
  <a href="https://github.com/meilisearch/meilisearch-swift/actions"><img src="https://github.com/meilisearch/meilisearch-swift/workflows/Tests/badge.svg" alt="GitHub Workflow Status"></a>
  <a href="https://github.com/meilisearch/meilisearch-swift/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-informational" alt="License"></a>
  <a href="https://app.bors.tech/repositories/28499"><img src="https://bors.tech/images/badge_small.svg" alt="Bors enabled"></a>
</p>

<p align="center">⚡ The MeiliSearch API client written in Swift 🍎</p>

**MeiliSearch-Swift** is a client for **MeiliSearch** written in Swift.

**MeiliSearch** is an open-source search engine. [Discover what MeiliSearch is!](https://github.com/meilisearch/MeiliSearch)
For more information about features go to [our Swift documentation](https://meilisearch.github.io/meilisearch-swift/).

## Get started

### Cocoapods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

**MeiliSearch-Swift** is available through [CocoaPods](https://cocoapods.org). To install
it, add the following line to your Podfile:

```ruby
pod 'MeiliSearch'
```

Then, run the following command:

```bash
pod install
```

This will download the latest version of MeiliSearch pod and prepare the `xcworkspace`.

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding **MeiliSearch-Swift** as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/meilisearch/meilisearch-swift.git")
]
```

## Basic setup

Make sure to firstly setup your `MeiliSearch` server. Please follow this getting started [here](https://docs.meilisearch.com/learn/tutorials/getting_started.html).

To do a simply search using the client, you can create a Swift script like this:

```swift
import MeiliSearch

func searchForMovies() {

    // Create a new client instance of MeiliSearch.
    let client = try! MeiliSearch(host: "http://localhost:7700")

    // Create a new search request with "botman" as query.
    let searchParameters = SearchParameters.query("botman")

    // Typealias that represents the result from Meili.
    typealias MeiliResult = Result<SearchResult<Movie>, Swift.Error>

    // Call the function search and wait for the closure result.
    self.client.search(UID: "movies", searchParameters) { (result: MeiliResult) in
        switch result {
        case .success(let searchResult):
            print(searchResult)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }

}

private struct Movie: Codable, Equatable {

    let id: Int
    let title: String
    let poster: String
    let overview: String
    let releaseDate: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case poster
        case overview
        case releaseDate = "release_date"
    }

}

```

## Compatibility with MeiliSearch

This package only guarantees the compatibility with the [version v0.21.0 of MeiliSearch](https://github.com/meilisearch/MeiliSearch/releases/tag/v0.21.0).

## Demo

To try out a demo you will need to go to its directory in `Demos/`. In that directory you can either:

 - Open the SwiftPM project in Xcode and press run, or
 - Run `swift build` or `swift run` in the terminal.

### Vapor

Please check the Vapor Demo source code [here](https://github.com/meilisearch/meilisearch-swift/tree/main/Demos/VaporDemo).

### Perfect

Please check the Perfect Demo source code [here](https://github.com/meilisearch/meilisearch-swift/tree/main/Demos/PerfectDemo).

## Development Workflow and Contributing

Any new contribution is more than welcome in this project!

If you want to know more about the development workflow or want to contribute, please visit our [contributing guidelines](/CONTRIBUTING.md) for detailed instructions!

## Contact

Feel free to [contact us](https://docs.meilisearch.com/learn/what_is_meilisearch/contact.html#contact-us) about any questions you may have.

Any suggestion or feedback is highly appreciated. Thank you for your support!

<hr>

**MeiliSearch** provides and maintains many **SDKs and Integration tools** like this one. We want to provide everyone with an **amazing search experience for any kind of project**. If you want to contribute, make suggestions, or just know what's going on right now, visit us in the [integration-guides](https://github.com/meilisearch/integration-guides) repository.
