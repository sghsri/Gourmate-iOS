//
//  NewUserViewController.swift
//  Gourmate-iOS
//
//  Created by Jennifer Suriadinata on 6/25/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit
import CoreData

// Cell in Cuisine Preferences table
class CuisincePrefCell : UITableViewCell {
    @IBOutlet weak var checkbox: CheckBox!
    @IBOutlet weak var cuisineLabel: UILabel!
}

// Cell in Dietary Restriction table
class DietaryRestrictionCell : UITableViewCell {
    @IBOutlet weak var checkbox: CheckBox!
    @IBOutlet weak var DRLabel: UILabel!
}

class NewUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var welcomeText: UILabelPadding!
    @IBOutlet weak var cuisineText: UILabelPadding!
    @IBOutlet weak var cuisineTable: UITableView!
    @IBOutlet weak var DRTable: UITableView!
    
    var cuisines = ["American", "Chinese", "Mexican", "Thai", "Japanese", "Indian"] // Types of cuisine
    var dietaryRestrictions = ["Vegetarian", "Vegan"] // Types of dietary restrictions
    
    var userCuisines:[String] = []
    var userDietaryRestrictions:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate and data source for tables
        cuisineTable.delegate = self
        cuisineTable.dataSource = self
        
        DRTable.delegate = self
        DRTable.dataSource = self
        
        print("Current User:", curUser)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
               print(data.value(forKey: "email") as! String)
          }
            
        } catch {
            
            print("Failed")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Add borders to welcome text
        welcomeText.layer.borderColor = UIColor.darkGray.cgColor
        welcomeText.layer.borderWidth = 1.0
        welcomeText.layer.cornerRadius = 8
        welcomeText.sizeToFit()
        
    }
    
    
    // Number of rows in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cuisineTable {
            return cuisines.count
        } else if tableView == DRTable{
            return dietaryRestrictions.count
        }
        print("ERROR: No table association")
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
            
            // Set identifier for checkbox
            cell.checkbox.isChecked = false // mark all as unchecked
            cell.checkbox.restorationIdentifier = "\(cuisines[indexPath.row])"
            
            return cell
        } else if tableView == DRTable {
            let cell = DRTable.dequeueReusableCell(withIdentifier: "DRTableCell", for: indexPath) as! DietaryRestrictionCell
            
            // Get text from DR array
            let DRText = dietaryRestrictions[indexPath.row]
            cell.DRLabel.text = DRText
            
            // Set identifier for checkbox
            cell.checkbox.isChecked = false // mark all as unchecked
            cell.checkbox.restorationIdentifier = "\(dietaryRestrictions[indexPath.row])"
            
            return cell
        }
        print ("No table association")
        return UITableViewCell()
    }
    
    func checkboxAddToArray( array: inout [String], checkbox: CheckBox){
        
        // Has just been unchecked
        if checkbox.isChecked {
            
            array.removeAll{$0 == checkbox.restorationIdentifier}
           
        // Has just been checked
        } else {
            array.append(checkbox.restorationIdentifier!)
        }
    }
    
    @IBAction func cuisineCheckbox(_ sender: Any) {
        checkboxAddToArray(array: &userCuisines, checkbox: sender as! CheckBox)
    }
    
    @IBAction func drCheckbox(_ sender: Any) {
        checkboxAddToArray(array: &userDietaryRestrictions, checkbox: sender as! CheckBox)
        
    }
    
    @IBAction func doneButton(_ sender: Any) {
        print(userCuisines)
        print(userDietaryRestrictions)
    }
    
}
