//
//  ViewController.swift
//  StoreSearch
//
//  Created by getTrickS2 on 2/7/18.
//  Copyright © 2018 Nik's. All rights reserved.
//

import UIKit

struct TableViewCellIndentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
}

class SearchViewController: UIViewController {
    
    // MARK: - Variables ================================
    var searchResults: [SearchResult] = []
    // ==================================================
    
    // MARK: - Outlets ==================================
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    // ==================================================
    
    // MARK: - Override functions ==========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.contentInset = UIEdgeInsets(top: 56, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        // Load cells to the tableView
        var cellNib = UINib(nibName: TableViewCellIndentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIndentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIndentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIndentifiers.nothingFoundCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // ======================================================================

}

// MARK: - Extensions =======================================================
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchResults = []
        for i in 0...2 {
            let searchResult = SearchResult(name: "Fake result \(i) for: ", artistName: searchBar.text!)
            searchResults.append(searchResult)
        }
        tableView.reloadData()
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count == 0 ? 1 : searchResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1. Create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIndentifiers.searchResultCell, for: indexPath) as! SearchResultCell
        // 2. Set cell
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIndentifiers.nothingFoundCell, for: indexPath)
        } else {
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel.text = searchResult.artistName
        }
        return cell
    }
}
// ==========================================================================
