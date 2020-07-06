//
//  GroupAnalysisViewController.swift
//  Gourmate-iOS
//
//  Created by Matthew Onghai on 7/5/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit

class DietaryGroupAnalysis: UITableViewCell {
    
    @IBOutlet weak var dietaryRestrictionText: UILabel!
}

class GroupAnalysisViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dietaryRestrictionTable: UITableView!
    @IBOutlet weak var cuisineAnalysisView: UIView!
    
    let dietaryRestrictions = ["Vegetarian", "Vegan"]
    
    var selectedUsers:[MateObject] = []
    
    // Create bar chart
    lazy var barChartView: BarChartView = {
        let barChartView = BarChartView()
        barChartView.frame = view.frame
        return barChartView
     }()
    
     override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set dietary restrictions table delegate and data source
        dietaryRestrictionTable.delegate = self
        dietaryRestrictionTable.dataSource = self
        
        // Types of cuisine
        let cuisines = ["American", "Chinese", "Mexican", "Thai", "Japanese", "Indian"]
        
        let userCuisines = self.aggregateCuisines()
        
        // Create bar entries for bar chart based on user cuisines
        var barEntries:[BarEntry] = []
        var totalCuisines = 0
        for cuisine in cuisines {
            let count = countMatch(value: cuisine, in: userCuisines)
            barEntries.append(BarEntry(score: count, title: cuisine))
            totalCuisines += count
        }
        
        // Check if in dark mode
        barChartView.darkMode = self.traitCollection.userInterfaceStyle == .dark
        
        // Set maximum bar length
        barChartView.maxBarLength = (totalCuisines == 0 ? 5 : totalCuisines) * 2
        
        // Create cuisine preferences bar chart
        barChartView.dataEntries = barEntries
        
        // Add to VC
        cuisineAnalysisView.addSubview(barChartView)
    }
    
    // Dietary Restriction table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dietaryRestrictions.count
    }
    
    // View for each dietary restriction
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dietaryRestrictionCell", for: indexPath) as! DietaryGroupAnalysis
        
        // Set dietary restriction text
        cell.dietaryRestrictionText.text = dietaryRestrictions[indexPath.row]
        
        // Set checkmark only if there is the restriction in the group
        let restrictionsList = self.aggregateRestrictions()
        let count = countMatch(value: dietaryRestrictions[indexPath.row], in: restrictionsList)
        if count != 0 {
            cell.accessoryType = .checkmark
        } else {
            print("No \(dietaryRestrictions[indexPath.row])")
        }
        
        return cell
    }
    
    // Find value in array and return index
    func countMatch(value searchValue: String, in array: [String]) -> Int {
        var count = 0
        for (_, value) in array.enumerated() {
            if value == searchValue {
                count += 1
            }
        }
        return count
    }
    
    // Get all cuisines from the selected users
    func aggregateCuisines() -> Array<String>{
        var cuisines:Array = Array<String>()
        for user in selectedUsers {
            for cuisine in user.cuisines {
                cuisines.append(cuisine)
            }
        }
        return Array(cuisines)
    }
    
    // Get all restrictions from the selected users
    func aggregateRestrictions() -> Array<String>{
        var restricts:Set = Set<String>()
        for user in selectedUsers {
            for rest in user.restrictions {
                if rest != "None"{
                    restricts.insert(rest)
                }
            }
        }
        return Array(restricts)
    }
}
