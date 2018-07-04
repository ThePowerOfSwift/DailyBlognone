//
//  BlognoneArticlesFetcher.swift
//  DailyBlognone
//
//  Created by Wirawit Rueopas on 4/7/18.
//

import AEXML

protocol BlognoneArticlesFetcherDelegate: class {
    func fetcher(_ fetcher: BlognoneArticlesFetcher, didSuccessfullyFetchArticles articles: [Article])
    func fetcher(_ fetcher: BlognoneArticlesFetcher, didFailToFetchWithError errorMessage: String)
}

final class BlognoneArticlesFetcher {

    static let url = URL(string: "https://www.blognone.com/atom.xml")!
    weak var delegate: BlognoneArticlesFetcherDelegate?
    var delegateOnMainThread = true

    func fetchNews() {
        let url = BlognoneArticlesFetcher.url
        DispatchQueue.global(qos: .background).async {
            let session = URLSession.shared
            let task = session.dataTask(with: url) { [weak self] (data, response, error) in
                guard let `self` = self else { return }
                if let error = error {
                    self.delegate?.fetcher(self, didFailToFetchWithError: error.localizedDescription)
                    return
                }
                guard let data = data else {
                    self.delegate?.fetcher(self, didFailToFetchWithError: "No xml data")
                    return
                }

                do {
                    let parser = try AEXMLDocument(xml: data)
                    let items = parser.root["channel"]["item"].all ?? []
                    let articles = items.compactMap(Article.init)
                    if self.delegateOnMainThread {
                        DispatchQueue.main.async {
                            self.delegate?.fetcher(self, didSuccessfullyFetchArticles: articles)
                        }
                    } else {
                        self.delegate?.fetcher(self, didSuccessfullyFetchArticles: articles)
                    }
                } catch {
                    if self.delegateOnMainThread {
                        DispatchQueue.main.async {
                            self.delegate?.fetcher(self, didFailToFetchWithError: error.localizedDescription)
                        }
                    } else {
                        self.delegate?.fetcher(self, didFailToFetchWithError: error.localizedDescription)
                    }
                }
                }
            task.resume()
        }
    }
}
