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
        
        // Label as "Notifications" or "Dark mode"
        cell.settingText.text = settings[indexPath.row]
        
        // Put identifier on switch
        cell.settingsSwitch.restorationIdentifier = "\(settings[indexPath.row]) Identifier"
        return cell
    }
    
    // Change Core Data for setting that switch is associated with
    @IBAction func changeSwitch(_ sender: Any) {
        let selectedSwitch = sender as! UISwitch
        
        // Notifications swtich
        if selectedSwitch.restorationIdentifier == "Notifications Identifier" {
            if selectedSwitch.isOn {
                print("Turned notifications on")
            } else {
                print("Turned notifications off")
            }
        
        // Dark mode switch
        } else if selectedSwitch.restorationIdentifier == "Dark Mode Identifier" {
            if selectedSwitch.isOn {
                print("Turned dark mode on")

                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .dark
                }

            } else {
                print("Turned dark mode off")

                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .light
                }

            }
        }
    }

}
