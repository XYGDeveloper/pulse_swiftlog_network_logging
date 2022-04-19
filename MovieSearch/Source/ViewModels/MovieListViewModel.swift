
import Foundation
import Combine
import Logging

final class MovieListViewModel: ObservableObject {
  @Published
  var movieList: [Movie] = []

  @Published
  var searchText: String = ""

  @Published
  var loading = false
  var currentTask: URLSessionDataTask?

  let networkService = NetworkService()
  let logger = Logger(label: "com.razeware.moviesearch")

  private var cancellables: Set<AnyCancellable> = []

  func search() {
    if let task = currentTask {
      task.cancel()
      currentTask = nil
    }

    DispatchQueue.main.async {
      guard !self.searchText.isEmpty else {
        self.movieList = []
        return
      }
    }

    logger.info("Performing search with term: \(self.searchText)")
    loading = true

    networkService.searchCompletion = processSearchResponse(result:)

    let task = networkService.search(for: searchText)
    currentTask = task
  }

  private func processSearchResponse(result: Result<[Movie], NetworkError>) {
    DispatchQueue.main.async {
      self.loading = false
      guard let list = try? result.get() else {
        return
      }

      self.movieList = list
    }
  }
}
