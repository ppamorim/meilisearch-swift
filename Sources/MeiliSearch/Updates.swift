import Foundation

/**
 Settings is a list of all the customization possible for an index.
 */
struct Updates {

  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  func get(
    _ UID: String,
    _ update: Update,
    _ completion: @escaping (Result<Update.Result, Swift.Error>) -> Void) {

    self.request.get(api: "/indexes/\(UID)/updates/\(update.updateId)") { result in

      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let result: Update.Result = try Constants.customJSONDecoder.decode(
            Update.Result.self,
            from: data)
          print("BEFORE COMPLETION IN GET")
          completion(.success(result))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }

    }

  }

  func getAll(
    _ UID: String,
    _ completion: @escaping (Result<[Update.Result], Swift.Error>) -> Void) {

    self.request.get(api: "/indexes/\(UID)/updates") { result in

      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let result: [Update.Result] = try Constants.customJSONDecoder.decode([Update.Result].self, from: data)

          completion(.success(result))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }

    }
  }

  func waitForPendingUpdate(
    _ UID: String,
    _ update: Update,
    _ options: WaitOptions? = nil,
    _ completion: @escaping (Result<Update.Result, Swift.Error>) -> Void) {

      let currentDate = Date()
      let waitOptions: WaitOptions = options ?? WaitOptions()
      var done = false
      while 0 - currentDate.timeIntervalSinceNow < waitOptions.timeOut || !done {
        print("1")
        print(update)
        let waitForGet = DispatchSemaphore(value: 0)
        self.get(UID, update) { result in
          switch result {
          case .success(let status):
            print("2")
            if status.status == Update.Status.processed || status.status == Update.Status.failed {
              print("3")
              done = true
              completion(.success(status))
              waitForGet.signal()
              return
            } else {
              print("4")
              sleep(1)
              waitForGet.signal()
            }
          case .failure(let error):
            print("5")
            done = true
            completion(.failure(error))
            waitForGet.signal()
          }
          print("6")
        }
        print("7")
        if done {
          return
        }
        print("8")
        waitForGet.wait() // does not work in test env
        print("9")
      }
      print("10")
      completion(.failure(MeiliSearch.Error.timeOut(timeOut: waitOptions.timeOut)))
      return
  }

}

// completion(.success(Update.Result(
        //   status: "processed",
        //   updateId: 1,
        //   type: Update.Result.UpdateType(
        //     name: "DocumentsAddition",
        //     number: 4
        //   ),
        //   duration: 0.076980613,
        //   enqueuedAt: Date("2019-12-07T21:16:09.623944Z"),
        //   processedAt: Date("2019-12-07T21:16:09.703509Z")
        // )))
