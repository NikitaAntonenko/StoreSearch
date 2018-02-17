//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by getTrickS2 on 2/17/18.
//  Copyright © 2018 Nik's. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
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



























