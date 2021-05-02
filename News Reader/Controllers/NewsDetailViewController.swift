//
//  NewsDetailViewController.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 28/04/21.
//

import UIKit
import WebKit

protocol NewsDetailViewControllerDelegate: class {
    func updateBookmarkList(isBookmarkNotDeleted: Bool, indexPath: IndexPath)
}

class NewsDetailViewController: UIViewController {
    
    //MARK: - Properties
    weak var delegate: NewsDetailViewControllerDelegate?
    private let indexPath: IndexPath
    private var newsDetailViewModel: NewsDetailViewModel {
        didSet {
            barButton.image = newsDetailViewModel.bookmarkImageIcon
        }
    }
    
    private let loadSpinner = UIActivityIndicatorView()
    private var barButton: UIBarButtonItem!
    var webView: WKWebView!
    
    //MARK: - Lifecycle
    
    init(detail: NewsDetail, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.newsDetailViewModel = NewsDetailViewModel(newsDetail: detail)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureView()
        loadWebView()
        cekBookmarkStatus()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.updateBookmarkList(isBookmarkNotDeleted: newsDetailViewModel.isBookmarked, indexPath: self.indexPath)
    }
    
    //MARK: - Selectors

    @objc private func didTapBookmarkButton() {
        if newsDetailViewModel.isBookmarked {
            newsDetailViewModel.deleteBookmark()
        } else {
            newsDetailViewModel.addBookmark()
        }
    }
    
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        title = ""
        let titleLable = UILabel()
        titleLable.text = newsDetailViewModel.category
        titleLable.textColor = .white
        titleLable.font = .systemFont(ofSize: 18)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLable)
        navigationItem.leftItemsSupplementBackButton = true
        
        barButton = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(didTapBookmarkButton))
        self.navigationItem.rightBarButtonItem = barButton
        
    }

    private func configureView() {
        
        loadSpinner.color = .black
        webView.addSubview(loadSpinner)
        loadSpinner.centerX(inView: webView, topAnchor: webView.topAnchor, paddingTop: 16)
    }
    
    private func loadWebView() {
        
        guard let url = newsDetailViewModel.detailUrl else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        webView.load(urlRequest)

    }
    
    private func cekBookmarkStatus() {
        newsDetailViewModel.cekBookmark()
    }
    
}

//MARK: - WKNavigationDelegate

extension NewsDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadSpinner.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadSpinner.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadSpinner.stopAnimating()

    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadSpinner.stopAnimating()
        webView.loadHTMLString(newsDetailViewModel.page, baseURL: nil)
    }

}

