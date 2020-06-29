//
//  NewUserViewController.swift
//  Gourmate-iOS
//
//  Created by Matthew Onghai on 6/25/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit

class CuisincePrefCell : UITableViewCell {
    
    @IBOutlet weak var checkbox: CheckBox!
    @IBOutlet weak var cuisineLabel: UILabel!
    
}

class NewUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var welcomeText: UILabelPadding!
    @IBOutlet weak var cuisineText: UILabelPadding!
    @IBOutlet weak var cuisineTable: UITableView!
    
    var cuisines = ["American", "Chinese", "Mexican", "Thai", "Japanese", "Indian"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cuisineTable.delegate = self
        cuisineTable.dataSource = self
        
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
    
    
    // Number of rows in Cuisine table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cuisines.count
    }
    
    // Data in Cuisine Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cuisineTable.dequeueReusableCell(withIdentifier: "cuisineTableCell", for: indexPath) as! CuisincePrefCell
        
        let cuisineText = cuisines[indexPath.row]
        cell.cuisineLabel.text = cuisineText
        
        return cell
        
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
