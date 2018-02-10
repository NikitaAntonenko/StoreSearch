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
    var hasSearched = false
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
        if !searchBar.text!.isEmpty {
            // Prepare
            searchBar.resignFirstResponder()
            hasSearched = true
            searchResults = []
            // 1. Get URL
            let url = iTunesURL(searchText: searchBar.text!)
            print("URL: \(url)")
            // 2. This invokes the request
            if let jsonString = performStoreRequest(with: url) {
                if let jsonDictionary = parse(json: jsonString) {
                    
                    searchResults = parse(dictionary: jsonDictionary)
                    searchResults.sort(by: <)
                    
                    tableView.reloadData()
                    return
                }
            }
            
        }
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
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
// For download from internet!
extension SearchViewController {
    // Inquiry building
    func iTunesURL(searchText: String) -> URL {
        // Decode into string without special characters
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapedSearchText)
        return URL(string: urlString)!
    }
    func performStoreRequest(with url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("Download Error: \(error)")
            return nil
        }
    }
    // Parse JSON into dictionary objects
    func parse(json: String) -> [String: Any]? {
        // Encode the json string with utf8
        guard let data = json.data(using: .utf8, allowLossyConversion: false)
            else { return nil }
        //
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    // Parse dictionary objects into SearchResults objects
    func parse(dictionary: [String: Any]) -> [SearchResult] {
        // Create array of accepted objects as 'Any' types
        guard let array = dictionary["results"] as? [Any] else {
            print("Expected 'results' array")
            return []
        }
        var searchResults: [SearchResult] = []
        // Let's parce each object
        for resultDict in array {
            if let resultDict = resultDict as? [String: Any] {
                var searchResult: SearchResult?
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
                // Save the parsed result
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
    func kindForDisplay(_ kind: String) -> String {
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "e-book": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: return kind
        }
    }
    
}
// ==========================================================================




















