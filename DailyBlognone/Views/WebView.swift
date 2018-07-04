//
//  WebView.swift
//  DailyBlognone
//
//  Created by Wirawit Rueopas on 4/7/18.
//

import ViewElements
import WebKit
import AEXML

typealias HTMLString = String

final class WebView: WKWebView, ElementDisplayable, OptionalTypedPropsAccessible {
    typealias PropsType = HTMLString

    var element: ElementOfView?
    private var heightConstraint: NSLayoutConstraint?

    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = false
        navigationDelegate = self

        heightConstraint = heightAnchor.constraint(equalToConstant: 400)
        heightConstraint?.priority = UILayoutPriority(999)
        heightConstraint?.isActive = true
    }

    func update() {
        guard let htmlContent = props else { return }
        DispatchQueue.global(qos: .background).async {
            do {
                let path = Bundle.main.path(forResource: "styles", ofType: "css")!
                let styles = try String(contentsOfFile: path).trimmingCharacters(in: .whitespacesAndNewlines)
                let wrapperContent = "<head><meta name='viewport' content='initial-scale=1.0'><style>\(styles)</style></head><body>\(htmlContent)</body>"
                DispatchQueue.main.async {
                    self.loadHTMLString(wrapperContent, baseURL: nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadHTMLString(htmlContent, baseURL: nil)
                }
            }
        }
    }

    static func buildMethod() -> ViewBuildMethod {
        return .init
    }
}

extension WebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    guard let height = height as? CGFloat else { return }
                    self.heightConstraint?.constant = height
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                })
            }
        })
    }
}
