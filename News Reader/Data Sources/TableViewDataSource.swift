//
//  TableViewDataSource.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 27/04/21.
//

import Foundation
import UIKit

class TableViewDataSource<CellType: UITableViewCell, ViewModel>: NSObject, UITableViewDataSource {
    
    let cellIdentifier: String
    var items: [ViewModel]
    let configureCell: (CellType, ViewModel) -> ()
    
    init(cellIdentifier: String, items: [ViewModel], configureCell: @escaping (CellType, ViewModel) -> ()) {
        self.cellIdentifier = cellIdentifier
        self.items = items
        self.configureCell = configureCell
    }
    
    func updateItems(_ items: [ViewModel]) {
        self.items = items
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? CellType else {
            fatalError("Cell with identifier \(self.cellIdentifier) not found")
        }
        
        let viewModel = self.items[indexPath.row]
        self.configureCell(cell, viewModel)
        return cell
    }
    
    
    
}
