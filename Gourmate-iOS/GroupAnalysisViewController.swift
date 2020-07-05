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
    @IBOutlet weak var checkmark: UIImageView!
}

class GroupAnalysisViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dietaryRestrictionTable: UITableView!
    @IBOutlet weak var cuisineAnalysisView: UIView!
    
    let dietaryRestrictions = ["Vegetarian", "Vegan"]
    
    // Create bar chart
    lazy var barChartView: BarChartView = {
        let barChartView = BarChartView()
        barChartView.frame = view.frame
        barChartView.maxBarLength = 5 * 2
        return barChartView
     }()
    
     override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set dietary restrictions table delegate and data source
        dietaryRestrictionTable.delegate = self
        dietaryRestrictionTable.dataSource = self
        
        let cuisines = ["American", "Chinese", "Mexican", "Thai", "Japanese", "Indian"] // Types of cuisine
        
        // Create cuisine preferences bar chart
        barChartView.dataEntries =
           [
              BarEntry(score: 1, title: cuisines[0]),
              BarEntry(score: 1, title: cuisines[1]),
              BarEntry(score: 5, title: cuisines[2]),
              BarEntry(score: 3, title: cuisines[3]),
              BarEntry(score: 2, title: cuisines[4]),
              BarEntry(score: 2, title: cuisines[5])
           ]
        cuisineAnalysisView.addSubview(barChartView) // Add to VC
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dietaryRestrictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dietaryRestrictionCell", for: indexPath) as! DietaryGroupAnalysis
        
        cell.dietaryRestrictionText.text = dietaryRestrictions[indexPath.row]
        cell.checkmark.frame = CGRect(x: 300, y: 20, width: 15, height: 15)
        
        cell.checkmark.image = UIImage.init(named: "checkmark")
        
        return cell
    }
}
