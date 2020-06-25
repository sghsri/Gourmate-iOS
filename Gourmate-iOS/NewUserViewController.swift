//
//  NewUserViewController.swift
//  Gourmate-iOS
//
//  Created by Matthew Onghai on 6/25/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit

class NewUserViewController: UIViewController {

    @IBOutlet weak var welcomeText: UILabelPadding!
    @IBOutlet weak var cuisineText: UILabelPadding!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Add borders
        welcomeText.layer.borderColor = UIColor.darkGray.cgColor
        welcomeText.layer.borderWidth = 1.0
        welcomeText.layer.cornerRadius = 8
        welcomeText.sizeToFit()
        
//        cuisineText.layer.borderColor = UIColor.darkGray.cgColor
//        cuisineText.layer.borderWidth = 1.0
//        cuisineText.layer.cornerRadius = 8
//        cuisineText.sizeToFit()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
