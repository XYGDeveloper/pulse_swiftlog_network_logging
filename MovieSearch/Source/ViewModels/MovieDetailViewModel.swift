
import SwiftUI

class MovieDetailViewModel: ObservableObject {
  let imageDownloader = ImageDownloader()

  @Published
  var posterImage: UIImage?

  func fetchImage(for movie: Movie, imageType: ImageType) {
    guard let posterPath = movie.posterPath else {
      return
    }

    imageDownloader.imageDownloadCompletion = processImageResponse(result:)
    imageDownloader.downloadImage(for: .list, at: posterPath)
  }

  private func processImageResponse(result: Result<UIImage, NetworkError>) {
    guard let image = try? result.get() else {
      return
    }

    DispatchQueue.main.async {
      self.posterImage = image
    }
  }
}
