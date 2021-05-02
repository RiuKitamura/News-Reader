//
//  BookmarkTableViewController.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 30/04/21.
//

import UIKit

class BookmarkTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    private var bookmarkListViewModel = BookmarkListViewModel()
    private var datasource: TableViewDataSource<NewsTableViewCell, NewsViewModel>!
    
    private let emptiStageLabel: UILabel = {
        let label = UILabel()
        label.text = "Bookmark kosong"
        return label
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        fetchData()
        
    }
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        title = "Bookmark"
    }
    
    private func configureTableView() {
        self.tableView.separatorStyle = .none
        // set empty stage label, to show message that bookmark is empty
        self.tableView.addSubview(emptiStageLabel)
        emptiStageLabel.center(inView: self.tableView)
        
        let identifier = "BookmarkCell"
        self.tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: identifier)
        self.datasource = TableViewDataSource(cellIdentifier: identifier, items: self.bookmarkListViewModel.bookmarkViewModels, configureCell: { (cell, vm) in
            // configure cell
            cell.viewModel = vm
            
        })
        
        self.tableView.dataSource = self.datasource
    }
    
    // fetch bookmark list data and reloda tableview
    private func fetchData() {
        self.bookmarkListViewModel.fetchData { (isSuccess) in
            if isSuccess {
                self.datasource.updateItems(self.bookmarkListViewModel.bookmarkViewModels)
                self.tableView.reloadData()
                self.updateEmptyStage()
            }
        }
    }
    
    // function to show or not the empty stage
    private func updateEmptyStage() {
        emptiStageLabel.isHidden = !bookmarkListViewModel.isDataEempty()
    }
}

//MARK: - UITableViewDelegate
extension BookmarkTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // go to news detail page if user click news in bookmark list
        let controller = NewsDetailViewController(detail: bookmarkListViewModel.bookmarkViewModels[indexPath.row].news, indexPath: indexPath)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - NewsDetailViewControllerDelegate
extension BookmarkTableViewController: NewsDetailViewControllerDelegate {
    // function get celled when user back from news detail page
    func updateBookmarkList(isBookmarkNotDeleted: Bool, indexPath: IndexPath) {
        // if the bookmark is deleted in detail view, update table bookmark list
        if !isBookmarkNotDeleted {
            bookmarkListViewModel.deleteRow(index: indexPath.row)
            self.datasource.updateItems(self.bookmarkListViewModel.bookmarkViewModels)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateEmptyStage()
        }
    }
}
