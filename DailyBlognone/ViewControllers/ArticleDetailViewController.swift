//
//  ArticleDetailViewController.swift
//  DailyBlognone
//
//  Created by Wirawit Rueopas on 4/7/18.
//

import WebKit

protocol ArticleDetailViewControllerDelegate: class {
    func articleDetail(_ viewController: ArticleDetailViewController, userDidTapOnURL url: URL)
}

final class ArticleDetailViewController: UIViewController {

    let article: Article
    private lazy var webView = WKWebView(frame: .zero)

    weak var delegate: ArticleDetailViewControllerDelegate?

    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Shouldn't instantiate from Xib")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ต้นฉบับ", style: .plain, target: self, action: #selector(goToOriginalLink))

        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        NotificationCenter.default.addObserver(self, selector: #selector(loadHTMLContent), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)

        loadHTMLContent()
    }

    @objc func loadHTMLContent() {
        DispatchQueue.global(qos: .background).async {
            let htmlContent = self.article.description
            let contentTitle = self.article.title
            let pubDate = self.article.pubDate
            let creator = self.article.creator
            do {
                let path = Bundle.main.path(forResource: "styles", ofType: "css")!
                let styles = try String(contentsOfFile: path).trimmingCharacters(in: .whitespacesAndNewlines)
                let wrapperContent = """
                <head>
                <meta name='viewport' content='initial-scale=1.0'>
                <style>\(styles)</style>
                </head>
                <body>
                <h1>
                    \(contentTitle)
                </h1>
                <h2>
                    By: \(creator)
                </h2>
                <h3>
                    \(pubDate.toLocal())
                </h3>
                <hr>
                <div>
                    \(htmlContent)
                </div>
                </body>
                """
                DispatchQueue.main.async {
                    self.webView.loadHTMLString(wrapperContent, baseURL: nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self.webView.loadHTMLString(htmlContent, baseURL: nil)
                }
            }
        }
    }

    @objc func goToOriginalLink() {
        let url = article.link
        delegate?.articleDetail(self, userDidTapOnURL: url)
    }
}

extension ArticleDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            if let url = navigationAction.request.url {
                decisionHandler(WKNavigationActionPolicy.cancel)
                delegate?.articleDetail(self, userDidTapOnURL: url)
            }
        default:
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
}
