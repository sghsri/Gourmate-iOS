//
//  NewUserViewController.swift
//  Gourmate-iOS
//
//  Created by Jennifer Suriadinata on 6/25/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit
import CoreData
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase

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
    var ref: DatabaseReference!
    var user: GIDGoogleUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate and data source for tables
        cuisineTable.delegate = self
        cuisineTable.dataSource = self
        DRTable.delegate = self
        DRTable.dataSource = self
        
        // Set up Firebase
        ref = Database.database().reference()
        user = GIDSignIn.sharedInstance()!.currentUser
        
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
            cell.checkbox.isChecked = find(value: cuisineText, in: userCuisines) // mark unchecked if not in list
            cell.checkbox.restorationIdentifier = "\(cuisines[indexPath.row])"
            return cell
            
        // Dietary Restriction Table
        } else if tableView == DRTable {
            let cell = DRTable.dequeueReusableCell(withIdentifier: "DRTableCell", for: indexPath) as! DietaryRestrictionCell
            
            // Get text from DR array
            let DRText = dietaryRestrictions[indexPath.row]
            cell.DRLabel.text = DRText
            
            // Set identifier for checkbox
            cell.checkbox.isChecked = find(value: DRText, in: userDietaryRestrictions) // mark unchecked if not in list
            cell.checkbox.restorationIdentifier = "\(dietaryRestrictions[indexPath.row])"
            return cell
        }
        print ("No table association")
        return UITableViewCell()
    }
    
    // Find value in array and return true/false
    func find(value searchValue: String, in array: [String]) -> Bool {
        for (_, value) in array.enumerated() {
            if value == searchValue {
                return true
            }
        }
        return false
    }
    
    // Add/remove preference to local array
    func checkboxAddToArray( array: inout [String], checkbox: CheckBox){
        
        // Has just been unchecked
        if checkbox.isChecked {
            
            array.removeAll{$0 == checkbox.restorationIdentifier}
            
        // Has just been checked
        } else {
            array.append(checkbox.restorationIdentifier!)
        }
    }
    
    // Add/remove cuisine preference
    @IBAction func cuisineCheckbox(_ sender: Any) {
        checkboxAddToArray(array: &userCuisines, checkbox: sender as! CheckBox)
    }
    
    // Add/remove dietary restriction
    @IBAction func drCheckbox(_ sender: Any) {
        checkboxAddToArray(array: &userDietaryRestrictions, checkbox: sender as! CheckBox)
    }
    
    // Create user in Firebase
    func createUser() {
        var userDP = URL(string: "")
        if (user?.profile.hasImage)! {
            userDP = user?.profile.imageURL(withDimension: 200)
        }
        
        if let userID = user?.userID  {
            let userObject: NSDictionary = [
                "uID" : userID,
                "email" : user?.profile.email,
                "name" : user?.profile.name,
                "givenName" : user?.profile.givenName,
                "image": userDP!.absoluteString,
                "cuisines": userCuisines,
                "restrictions": userDietaryRestrictions.count > 0 ? userDietaryRestrictions : ["None"]
            ]
            self.ref.child("users/\(userID)").setValue(userObject)
        }
    }
    
    // Save data and segue to next screen
    @IBAction func doneButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        self.createUser()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        
        // Set up user in Core Data
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        let curEmail = GIDSignIn.sharedInstance()!.currentUser.profile.email
        newUser.setValue(curEmail, forKey: "email")
        newUser.setValue(false, forKey: "location")
        newUser.setValue(true, forKey: "darkMode")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        
        curUser = newUser // Save current user globally
        curUserEmail = curEmail
        
    }
    
}
