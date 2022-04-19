
import UIKit
import PulseCore

class ImageDownloader: NSObject {
  private let imageBaseURLString = "https://image.tmdb.org"

  let urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
  let logger = NetworkLogger()

  var imageDownloadCompletion: ((Result<UIImage, NetworkError>) -> Void)?

  func downloadImage(for imageType: ImageType, at path: String) {
    guard let url = try? url(for: imageType, at: path) else {
      return
    }

    let task = urlSession.dataTask(with: url)
    task.delegate = self
    task.resume()
  }

  private func url(for imageType: ImageType, at path: String) throws -> URL {
    let imagePathParam = imageType.pathParameter()
    guard let baseURL = URL(string: imageBaseURLString),
      var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
        throw NetworkError.invalidURL
      }

    urlComponents.path = "/t/p/\(imagePathParam)\(path)"

    let queryItems: [URLQueryItem] = [
      URLQueryItem(name: "api_key", value: APIKey.value)
    ]

    urlComponents.queryItems = queryItems

    guard let url = urlComponents.url else {
      throw NetworkError.invalidURL
    }

    return url
  }
}

extension ImageDownloader: URLSessionTaskDelegate, URLSessionDataDelegate {
  func urlSession(
    _ session: URLSession,
    dataTask: URLSessionDataTask,
    didReceive response: URLResponse,
    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
  ) {
    logger.logDataTask(dataTask, didReceive: response)

    if let response = response as? HTTPURLResponse,
      response.statusCode != 200 {
      imageDownloadCompletion?(.failure(.invalidResponseType))
    }

    completionHandler(.allow)
  }

  func urlSession(
    _ session: URLSession,
    task: URLSessionTask,
    didCompleteWithError error: Error?
    ) {
    logger.logTask(task, didCompleteWithError: error)
    imageDownloadCompletion?(.failure(NetworkError.invalidResponseType))
  }

  func urlSession(
    _ session: URLSession,
    task: URLSessionTask,
    didFinishCollecting metrics: URLSessionTaskMetrics
    ) {
    logger.logTask(task, didFinishCollecting: metrics)
  }

  func urlSession(
    _ session: URLSession,
    dataTask: URLSessionDataTask,
    didReceive data: Data
    ) {
    logger.logDataTask(dataTask, didReceive: data)
    guard let image = UIImage(data: data) else {
      imageDownloadCompletion?(.failure(.invalidParse))
      return
    }
    imageDownloadCompletion?(.success(image))
  }
}
