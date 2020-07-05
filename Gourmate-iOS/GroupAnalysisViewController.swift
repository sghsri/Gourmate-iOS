//
//  GroupAnalysisViewController.swift
//  Gourmate-iOS
//
//  Created by Matthew Onghai on 7/5/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit

class GroupAnalysisViewController: UIViewController {
    
    @IBOutlet weak var cuisineAnalysisView: UIView!
    
    lazy var barChartView: BarChartView = {
        let barChartView = BarChartView()
        barChartView.frame = view.frame
        barChartView.maxBarLength = 5 * 2
        return barChartView
     }()
    
     override func viewDidLoad() {
        super.viewDidLoad()
        
        let cuisines = ["American", "Chinese", "Mexican", "Thai", "Japanese", "Indian"] // Types of cuisine
        
        barChartView.dataEntries =
           [
              BarEntry(score: 1, title: cuisines[0]),
              BarEntry(score: 1, title: cuisines[1]),
              BarEntry(score: 5, title: cuisines[2]),
              BarEntry(score: 3, title: cuisines[3]),
              BarEntry(score: 2, title: cuisines[4]),
              BarEntry(score: 2, title: cuisines[5])
           ]
        cuisineAnalysisView.addSubview(barChartView)
    }
}
