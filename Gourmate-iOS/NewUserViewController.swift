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

class DietaryRestrictionCell : UITableViewCell {
    @IBOutlet weak var checkbox: CheckBox!
    @IBOutlet weak var DRLabel: UILabel!
}

class NewUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var welcomeText: UILabelPadding!
    @IBOutlet weak var cuisineText: UILabelPadding!
    @IBOutlet weak var cuisineTable: UITableView!
    @IBOutlet weak var DRTable: UITableView!
    
    var cuisines = ["American", "Chinese", "Mexican", "Thai", "Japanese", "Indian"]
    
    var dietaryRestrictions = ["Vegetarian", "Vegan"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate and data source for tables
        cuisineTable.delegate = self
        cuisineTable.dataSource = self
        
        DRTable.delegate = self
        DRTable.dataSource = self
        
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
    
    
    // Number of rows in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cuisineTable {
            return cuisines.count
        } else if tableView == DRTable{
            return dietaryRestrictions.count
        }
        print("No table association")
        return 0
    }
    
    // Data in cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Cuisine Table
        if tableView == cuisineTable {
            let cell = cuisineTable.dequeueReusableCell(withIdentifier: "cuisineTableCell", for: indexPath) as! CuisincePrefCell
            
            // Get text from cuisines array
            let cuisineText = cuisines[indexPath.row]
            cell.cuisineLabel.text = cuisineText
            
            return cell
        } else if tableView == DRTable {
            let cell = DRTable.dequeueReusableCell(withIdentifier: "DRTableCell", for: indexPath) as! DietaryRestrictionCell
            
            // Get text from DR array
            let DRText = dietaryRestrictions[indexPath.row]
            cell.DRLabel.text = DRText
            
            return cell
        }
        print ("No table association")
        return UITableViewCell()
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
