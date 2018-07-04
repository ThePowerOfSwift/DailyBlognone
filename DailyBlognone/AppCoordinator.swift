//
//  AppCoordinator.swift
//  DailyBlognone
//
//  Created by Wirawit Rueopas on 4/7/18.
//

import UIKit
import SafariServices

final class AppCoordinator {

    weak var navigation: UINavigationController?

    init(window: UIWindow) {
        navigation = window.rootViewController as? UINavigationController
        let listVc = navigation!.viewControllers.first! as! ArticleListViewController
        listVc.delegate = self
    }
}

extension AppCoordinator: ArticleListViewControllerDelegate {
    func articleList(_ viewController: ArticleListViewController, didTapArticle article: Article) {
        let vc = ArticleDetailViewController(article: article)
        vc.delegate = self
        viewController.show(vc, sender: nil)
    }
}

extension AppCoordinator: ArticleDetailViewControllerDelegate {
    func articleDetail(_ viewController: ArticleDetailViewController, userDidTapOnURL url: URL) {
        let isValidURL = UIApplication.shared.canOpenURL(url)
        if isValidURL {
            let vc = SFSafariViewController(url: url)
            viewController.present(vc, animated: true)
        }
    }
}
