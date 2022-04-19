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

import SwiftUI

struct MovieRowView: View {
  let defaultImage = UIImage(systemName: "film")

  let movie: Movie

  @ObservedObject
  var viewModel = MovieDetailViewModel()

  init(movie: Movie) {
    self.movie = movie
    viewModel.fetchImage(for: movie, imageType: .detail)
  }

  var body: some View {
    Group {
      HStack(alignment: .center) {
        if let downloadedImage = viewModel.posterImage {
          Image(uiImage: downloadedImage)
            .resizable()
            .frame(width: 100, height: 160, alignment: .center)
            .cornerRadius(5)
            .padding()
        } else {
          Image(systemName: "film")
            .resizable()
            .frame(width: 100, height: 160, alignment: .center)
            .foregroundColor(.white)
            .padding()
        }

        VStack(alignment: .leading) {
          Group {
            Text(movie.title)
              .fontWeight(.black)
              .font(.system(.headline))
            Text(movie.displayReleaseDate() ?? "")
              .fontWeight(.light)
              .foregroundColor(.gray)
            Text(movie.overview)
              .lineLimit(3)
          }
          .padding(.bottom, 10)
        }
        .padding(.horizontal, 20)
      }
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .cornerRadius(25)
    .padding(.all, 5)
  }
}

// swiftlint:disable line_length
struct MovieRow_Previews: PreviewProvider {
  static var previews: some View {
    MovieRowView(
      movie: Movie(
        id: 0,
        title: "The Matrix",
        overview: "Set in the 22nd century, The Matrix tells the story of a computer hacker who joins a group of underground insurgents fighting the vast and powerful computers who now rule the earth.",
        voteAverage: 5.0,
        posterPath: nil,
        releaseDate: "1999-03-30"))
  }
}
