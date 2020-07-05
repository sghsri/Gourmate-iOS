//
//  SettingsViewController.swift
//  Gourmate-iOS
//
//  Created by Matthew Onghai on 6/18/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

// Settings Table custom cell
class SettingsTableCell: UITableViewCell {
    
    @IBOutlet weak var settingText: UILabel!
    @IBOutlet weak var settingsSwitch: UISwitch!
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var qrCodeimage: UIImageView!
    
    @IBOutlet weak var settingsTable: UITableView!
    
    var settings = ["Notifications", "Dark Mode"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTable.delegate = self
        settingsTable.dataSource = self
        self.qrCodeimage.image = generateQRCode(from: "https://www.google.com")
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
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
        
        // Set switch on/off
        if settings[indexPath.row] == "Dark Mode" {
            cell.settingsSwitch.isOn = curUser.value(forKey: "darkMode") as! Bool
        }
        else if settings[indexPath.row] == "Notifications" {
            cell.settingsSwitch.isOn = curUser.value(forKey: "notifications") as! Bool
        }
        
        return cell
    }
    
    // Change Core Data for setting that switch is associated with
    @IBAction func changeSwitch(_ sender: Any) {
        let selectedSwitch = sender as! UISwitch
        
        // Notifications swtich
        if selectedSwitch.restorationIdentifier == "Notifications Identifier" {
            if selectedSwitch.isOn {
                print("Turned notifications on")
                UNUserNotificationCenter.current().requestAuthorization(options: .alert, completionHandler: {
                    (success, error) in
                    if success {
                        curUser.setValue(true, forKey: "notifications")
                    } else {
                        UIApplication.shared.unregisterForRemoteNotifications()
                        selectedSwitch.isOn = false
                    }
                })
            } else {
                print("Turned notifications off")
                UIApplication.shared.unregisterForRemoteNotifications()
                curUser.setValue(false, forKey: "notifications")
            }
        
        // Dark mode switch
        } else if selectedSwitch.restorationIdentifier == "Dark Mode Identifier" {
            if selectedSwitch.isOn {
                print("Turned dark mode on")
                curUser.setValue(true, forKey: "darkMode")

                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .dark
                }

            } else {
                print("Turned dark mode off")
                curUser.setValue(false, forKey: "darkMode")

                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .light
                }

            }
        }
    }

}
