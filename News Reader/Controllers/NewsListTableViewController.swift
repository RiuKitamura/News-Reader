//
//  NewsListTableViewController.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 27/04/21.
//

import UIKit

class NewsListTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    private var newsListViewModel = NewsListViewModel()
    private var datasource: TableViewDataSource<NewsTableViewCell, NewsViewModel>!
    
    private let footerLoadSpinner = UIActivityIndicatorView()
    
    private let emptiStageLabel: UILabel = {
        let label = UILabel()
        label.text = "Tidak bisa load data"
        label.isHidden = true
        return label
    }()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
        fetchData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimatingProcess()
    }
    
    //MARK: - Selectors
    
    @objc private func didTapBookmarkButton() {
        let controller = BookmarkTableViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func handleRefresh() {
        fetchData()
    }
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        // set navigation titleview
        let logo = UIImage(named: "detikcom")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // set bookmark navigation button
        let barButton = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(didTapBookmarkButton))
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    private func configureTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.addSubview(emptiStageLabel)
        emptiStageLabel.center(inView: self.tableView)
        
        let identifier = "NewsCell"
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: identifier)
        self.datasource = TableViewDataSource(cellIdentifier: identifier, items: self.newsListViewModel.newsViewModels, configureCell: { (cell, vm) in
            // configure cell
            cell.viewModel = vm
            cell.delegate = self
        })
        
        self.tableView.dataSource = self.datasource
        
        // add slide top refreshcontrol to tableview
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    private func fetchData(link: String? = nil) {
        
        var linkString = ""
        var sholdRefresh = false
        if link == nil {
            // for fetch initial data (at the beginning)
            linkString = Constans.Urls.urlForNews
            sholdRefresh = true
            self.tableView.refreshControl?.beginRefreshing()
        } else {
            // for fetch next page data
            footerLoadSpinner.startAnimating()
            linkString = link!
        }
        
        // fetch data
        self.newsListViewModel.fetchData(with: linkString, isRefreshingData: sholdRefresh) { (isSuccessed) in
            if isSuccessed {
                self.datasource.updateItems(self.newsListViewModel.newsViewModels)
                self.tableView.reloadData()
            }
            
            self.emptiStageLabel.isHidden = self.newsListViewModel.shouldHideEmptyStage()
            
            // stop loading indicator
            self.tableView.refreshControl?.endRefreshing()
            self.footerLoadSpinner.stopAnimating()
        }
    }
    
    private func stopAnimatingProcess() {
        self.tableView.refreshControl?.endRefreshing()
        self.footerLoadSpinner.stopAnimating()
    }
}

//MARK: - UITableViewDelegate
extension NewsListTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // go to news detail page when news get click
        let controller = NewsDetailViewController(detail: newsListViewModel.newsViewModels[indexPath.row].news, indexPath: indexPath)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // when user scroll to the end of data, call function to fetch next page data
        let minimumTrigger = scrollView.bounds.size.height + 10
        
        if scrollView.contentSize.height > minimumTrigger {
            
            let distanceFromBottom = scrollView.contentSize.height - (scrollView.bounds.size.height - scrollView.contentInset.bottom) - scrollView.contentOffset.y
            
            if distanceFromBottom < 10 && !self.newsListViewModel.isLoading {
                fetchData(link: self.newsListViewModel.nextPageLink)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerLoadSpinner
    }
}

//MARK: - NewsTableViewCellDelegate
extension NewsListTableViewController: NewsTableViewCellDelegate {
    
    // function get called when user swife news title
    func didSwipeBookmark(cell: NewsTableViewCell, isShown: Bool) {
        
        // show or hide bookmark button animation
        if isShown {
            cell.lineConstraint?.constant = 80
            cell.arrowConstraint?.constant = 96
        } else {
            cell.lineConstraint?.constant = -1
            cell.arrowConstraint?.constant = -16
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        if isShown {
            // cek if news already in bookmark list or not
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            newsListViewModel.cekBookmark(index: indexPath.row)
            // set bookmark button icon and title
            cell.bookmarkButton.topImageView.image = newsListViewModel.newsViewModels[indexPath.row].bookmarkImage
            cell.bookmarkButton.titleTextLabel.text = newsListViewModel.newsViewModels[indexPath.row].bookmarkTitle
        }
    }
    
    // function get call if user click bookmark button
    func didClickBookmark(cell: NewsTableViewCell) {
        
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        
        // if news already bookmarked, delete it
        if newsListViewModel.newsViewModels[indexPath.row].isBookmarked {
            newsListViewModel.deleteBookmark(index: indexPath.row)
            cell.bookmarkButton.topImageView.image = newsListViewModel.newsViewModels[indexPath.row].bookmarkImage
            cell.bookmarkButton.titleTextLabel.text = newsListViewModel.newsViewModels[indexPath.row].bookmarkTitle
            
        } else {
            // add new bookmark
            newsListViewModel.addBookmark(index: indexPath.row)
            cell.bookmarkButton.topImageView.image = newsListViewModel.newsViewModels[indexPath.row].bookmarkImage
            cell.bookmarkButton.titleTextLabel.text = newsListViewModel.newsViewModels[indexPath.row].bookmarkTitle
        }
    }
}
