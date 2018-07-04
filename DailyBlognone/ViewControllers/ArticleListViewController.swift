//
//  ArticleListViewController.swift
//  DailyBlognone
//
//  Created by Wirawit Rueopas on 4/7/18.
//

import ViewElements
import GoogleMobileAds

protocol ArticleListViewControllerDelegate: class {
    func articleList(_ viewController: ArticleListViewController, didTapArticle article: Article)
}

final class ArticleListViewController: TableModelViewController {

    private lazy var refreshControl = UIRefreshControl()
    private lazy var ad = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)

    private lazy var fetcher = BlognoneArticlesFetcher()
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

    private func setupAdView() {
        ad.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ad)
        view.bringSubview(toFront: ad)
        ad.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        ad.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        ad.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        ad.rootViewController = self
        let req = GADRequest()
        req.testDevices = [kGADSimulatorID]
        ad.load(req)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        ad.adSize =  UIDevice.current.orientation.isPortrait ? kGADAdSizeSmartBannerPortrait : kGADAdSizeSmartBannerLandscape
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)

        setupAdView()

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
