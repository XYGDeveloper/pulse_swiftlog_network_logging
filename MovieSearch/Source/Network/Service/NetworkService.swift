/// Copyright (c) 2022 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import PulseCore

class NetworkService: NSObject {
  private let baseURLString = "https://api.themoviedb.org"
  private let imageBaseURLString = "https://image.tmdb.org"

  let urlSession = URLSession(configuration: URLSessionConfiguration.default)
  let logger = NetworkLogger()
  var searchCompletion: ((Result<[Movie], NetworkError>) -> Void)?

  @discardableResult
  func search(for searchTerm: String) -> URLSessionDataTask? {
    guard let url = try? url(for: searchTerm) else {
      searchCompletion?(.failure(NetworkError.invalidURL))
      return nil
    }

    let task = urlSession.dataTask(with: url)
    task.delegate = self
    task.resume()
    return task
  }

  private func url(for searchTerm: String) throws -> URL {
    guard let baseURL = URL(string: baseURLString),
      var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
        throw NetworkError.invalidURL
          }

    urlComponents.path = "/3/search/movie"

    let queryItems: [URLQueryItem] = [
      URLQueryItem(name: "api_key", value: APIKey.value),
      URLQueryItem(name: "language", value: "en-us"),
      URLQueryItem(name: "query", value: searchTerm),
      URLQueryItem(name: "page", value: "1")
    ]

    urlComponents.queryItems = queryItems
    guard let url = urlComponents.url else {
      throw NetworkError.invalidURL
    }

    return url
  }
}

extension NetworkService: URLSessionTaskDelegate, URLSessionDataDelegate {
  func urlSession(
    _ session: URLSession,
    dataTask: URLSessionDataTask,
    didReceive response: URLResponse,
    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
  ) {
    logger.logDataTask(dataTask, didReceive: response)
    if let response = response as? HTTPURLResponse,
      response.statusCode != 200 {
      searchCompletion?(.failure(.invalidResponseType))
    }

    completionHandler(.allow)
  }

  func urlSession(
    _ session: URLSession,
    task: URLSessionTask,
    didCompleteWithError error: Error?
  ) {
    logger.logTask(task, didCompleteWithError: error)
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

    do {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase

      let movieResponse = try decoder.decode(MovieResponse.self, from: data)
      searchCompletion?(.success(movieResponse.list))
    } catch {
      searchCompletion?(.failure(NetworkError.invalidParse))
    }
  }
}
