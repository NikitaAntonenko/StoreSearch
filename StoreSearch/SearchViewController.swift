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
    static let loadingCell = "LoadingCell"
}

class SearchViewController: UIViewController {
    
    // MARK: - Variables ================================
    var searchResults: [SearchResult] = []
    var dataTask: URLSessionDataTask?
    var hasSearched = false
    var isLoading = false
    // ==================================================
    
    // MARK: - Outlets ==================================
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    // ==================================================
    
    // MARK: - Actions ==================================
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    // ==================================================

    // MARK: - Override functions ==========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //tableView.contentInset = UIEdgeInsets(top: 56, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        // Register cells to the tableView
        var cellNib = UINib(nibName: TableViewCellIndentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIndentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIndentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIndentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIndentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIndentifiers.loadingCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let controller = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            controller.searchResult = searchResults[indexPath.row]
        }
    }
    // ======================================================================

}

// MARK: - Extensions =======================================================
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { // For "LoadingCell"
            return 1
        } else if !hasSearched { // For nothihing (in start)
            return 0
        } else if searchResults.count == 0 { // For "NothingFoundCell"
            return 1
        } else { // For "SearchResultCell"
            return searchResults.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1. Create cell
        
        // 1. Set cell
        if isLoading { // 1.1 If is loading - LoadingCell
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIndentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if searchResults.count == 0 { // 1.2 If the search results is empty - NothingFoundCell
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIndentifiers.nothingFoundCell, for: indexPath)
        } else { // 1.3 If all right - SearchResultCells
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIndentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            cell.configure(for: searchResults[indexPath.row])
            return cell
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
}

// Functions for searching and download objects from iTunes!
extension SearchViewController {
    func performSearch() {
        if !searchBar.text!.isEmpty {
            // 1. Prepare
            dataTask?.cancel() // if it possible stop the later task
            searchBar.resignFirstResponder()
            isLoading = true
            hasSearched = true
            searchResults = []
            tableView.reloadData()
            // 2. Get URL
            let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            // 3. Obtain the URLSession object
            let session = URLSession.shared
            // 4. Create a data task which are for sending HTTPS GET requests to the server
            dataTask = session.dataTask(with: url) {
                data, response, error in
                
                if let error = error as NSError?, error.code == -999 {
                    return
                } else if let httpResponse = response as? HTTPURLResponse, // if everything good
                    httpResponse.statusCode == 200 { // all downloaded - status code
                    // 4.1 Let's unwrap the accepting data, and parse it to dictionary
                    if let data = data, let jsonDictionary = self.parse(json: data) {
                        // 4.2 Parse to [SearchResults]
                        self.searchResults = self.parse(dictionary: jsonDictionary)
                        self.searchResults.sort(by: <)
                        
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                } else {
                    print(response ?? "Wow")
                }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.hasSearched = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
                
            }
            // 5. Call resume() to start sending the request to the server
            dataTask?.resume()
        }
    }
    // Inquiry building
    func iTunesURL(searchText: String, category: Int) -> URL {
        // 1. If category is selected or not
        let entityName: String
        switch category {
        case 1: entityName = "musicTrack"
        case 2: entityName = "software"
        case 3: entityName = "ebook"
        default: entityName = ""
        }
        // 2. Decode 'searchText' into string without special characters
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        // 3. Add a destination
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        // 3. Create and return URL
        return URL(string: urlString)!
    }
    // Perform Serialization (parse JSON into dictionary object)
    func parse(json data: Data) -> [String: Any]? {
        // Perform Serialization
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    // Parse dictionary objects into SearchResults objects
    func parse(dictionary: [String: Any]) -> [SearchResult] {
        // 1. Create array of accepted objects as 'Any' types
        guard let array = dictionary["results"] as? [Any] else {
            print("Expected 'results' array")
            return []
        }
        var searchResults: [SearchResult] = []
        // 2. Let's parce each object
        for resultDict in array {
            if let resultDict = resultDict as? [String: Any] {
                // 2.1 Create entity
                var searchResult: SearchResult?
                // 2.2 Parse in depending on which "wrapperType" is
                if let wrapperType = resultDict["wrapperType"] as? String {
                    switch wrapperType {
                    case "track": searchResult = parse(track: resultDict)
                    case "audiobook": searchResult = parse(audiobook: resultDict)
                    case "software": searchResult = parse(software: resultDict)
                    default: break
                    }
                } else if let kind = resultDict["kind"] as? String, kind == "ebook" {
                    searchResult = parse(ebook: resultDict)
                }
                // 2.3 Save the parsed result
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        return searchResults
    }
    // Parse track into SearchResult
    func parse(track dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    // Parse audiobook into SearchResult
    func parse(audiobook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    // Parse software into SearchResult
    func parse(software dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    // Parse ebook into SearchResult
    func parse(ebook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        
        if let genres = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joined(separator: ", ")
        }
        
        return searchResult
    }
    // Alert
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error reading from the iTunes Store. Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}
// ==========================================================================




















