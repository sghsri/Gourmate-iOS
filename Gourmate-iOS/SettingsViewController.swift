//
//  SettingsViewController.swift
//  Gourmate-iOS
//
//  Created by Matthew Onghai on 6/18/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit

// Settings Table custom cell
class SettingsTableCell: UITableViewCell {
    
    @IBOutlet weak var settingText: UILabel!
    @IBOutlet weak var settingsSwitch: UISwitch!
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var settingsTable: UITableView!
    
    var settings = ["Notifications", "Dark Mode"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTable.delegate = self
        settingsTable.dataSource = self
    }
    
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count;
    }
    
    // Data for cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTable.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsTableCell
        
        cell.settingText.text = settings[indexPath.row]
//        cell.settingsSwitch.isOn
        return cell
    }
    
    // Change Core Data for setting that switch is associated with
    @IBAction func changeSwitch(_ sender: Any) {
        let selectedSwitch = sender as! UISwitch
        print(selectedSwitch.isOn)
    }

}
