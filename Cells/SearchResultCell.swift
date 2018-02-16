//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by getTrickS2 on 2/9/18.
//  Copyright © 2018 Nik's. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    // MARK: - Outlets ========================
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    // ========================================
    
    // MARK: - Variables ======================
    var downloadTask: URLSessionDownloadTask?
    // ========================================
    
    // MARK: - Functions ======================
    func configure(for searchResult: SearchResult) {
        // 1. Set the nameLabel
        nameLabel.text = searchResult.name
        // 2. Set the artistNameLabel
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = String(format: "%@ (%@)",searchResult.artistName, kindForDisplay(searchResult.kind))
        }
        // 3. Set the Image
        artworkImageView.image = #imageLiteral(resourceName: "Placeholder")
        if let smallURL = URL(string: searchResult.artworkSmallURL) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
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
    // ========================================
    
    // MARK: - Override functions =============
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // ========================================
}
