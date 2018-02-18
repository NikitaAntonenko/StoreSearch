//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by getTrickS2 on 2/17/18.
//  Copyright © 2018 Nik's. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - Outlets =============================
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindValueLabel: UILabel!
    @IBOutlet weak var genreValueLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    // =============================================
    
    // MARK: - Variables ===========================
    var searchResult: SearchResult?
    // =============================================
    
    // MARK: - Actions =============================
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    // =============================================
    
    // MARK: - Inits ===============================
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    // =============================================
    
    // MARK: - Override functions ==================
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set screen
        if let searchResult = searchResult {
            // 1. Set Image
            imageView.image = #imageLiteral(resourceName: "Placeholder")
            if let largeURL = URL(string: searchResult.artworkLargeURL) {
                _ = imageView.loadImage(url: largeURL)
            }
            // 2. Set Name
            nameLabel.text = searchResult.name
            // 3. Set Artist Name
            artistNameLabel.text = searchResult.artistName
            // 4. Set Kind Value
            kindValueLabel.text = searchResult.kind
            // 5. Set Genre Value
            genreValueLabel.text = searchResult.genre
            // 6. Set Price Button
            priceButton.setTitle(String(format: "$%.2f", searchResult.price), for: .normal) 
        }
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // =============================================
}

// MARK: - Extentions ==========================
extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
// =============================================



























