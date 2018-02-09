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
    
    // MARK: - Override functions =============
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
