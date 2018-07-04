//
//  ArticleListViewController.swift
//  DailyBlognone
//
//  Created by Wirawit Rueopas on 4/7/18.
//

import ViewElements

protocol ArticleListViewControllerDelegate: class {
    func articleList(_ viewController: ArticleListViewController, didTapArticle article: Article)
}

final class ArticleListViewController: TableModelViewController {

    private lazy var fetcher = BlognoneArticlesFetcher()
    private lazy var refreshControl = UIRefreshControl()
    private var articles: [Article]?

    weak var delegate: ArticleListViewControllerDelegate?

    override func setupTable() {
        table = Table {[
            Row(ElementOfActivityIndicator()),
            Row(ElementOfLabel(props: "Loading").styles({ (lb) in
                lb.textAlignment = .center
            }))
        ]}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        fetcher.delegate = self
        fetcher.fetchNews()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let articles = self.articles else { return }
        delegate?.articleList(self, didTapArticle: articles[indexPath.row])
    }

    @objc func refresh() {
        refreshControl.beginRefreshing()
        fetcher.fetchNews()
    }
}

extension ArticleListViewController: BlognoneArticlesFetcherDelegate {

    func fetcher(_ fetcher: BlognoneArticlesFetcher, didSuccessfullyFetchArticles articles: [Article]) {
        refreshControl.endRefreshing()
        self.articles = articles
        table = Table { () -> [Row] in
            return articles.map { a in
                let row = Row(self.elementOfArticleListItem(article: a))
                row.separatorStyle = .fullWidth
                return row
            }
        }
        tableView.reloadData()
    }

    func fetcher(_ fetcher: BlognoneArticlesFetcher, didFailToFetchWithError errorMessage: String) {
        refreshControl.endRefreshing()
        let err = "Error:\n\(errorMessage)"
        table = Table { [Row(ElementOfLabel(props: err))] }
        tableView.reloadData()
    }
}

private extension ArticleListViewController {
    func elementOfArticleListItem(article: Article) -> ElementOf<ArticleListItemView> {
        return ElementOf<ArticleListItemView>.init(props: (article.title, article.pubDate.toLocal()))
    }
}
