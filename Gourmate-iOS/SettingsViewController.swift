//
//  SettingsViewController.swift
//  Gourmate-iOS
//
//  Created by Jennifer Suriadinata on 6/18/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit
import CoreData
import GoogleSignIn

// Settings Table custom cell
class SettingsTableCell: UITableViewCell {
    
    @IBOutlet weak var settingText: UILabel!
    @IBOutlet weak var settingsSwitch: UISwitch!
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var qrCodeimage: UIImageView!
    @IBOutlet weak var settingsTable: UITableView!
    
    var settings = ["Dark Mode", "Location"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Settings table
        settingsTable.delegate = self
        settingsTable.dataSource = self
        
        // Get QR Code
        self.qrCodeimage.image = generateQRCode(from: (GIDSignIn.sharedInstance()?.currentUser.profile.email)!)
    }
    
    // Generate QR Code based on unique email
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
        
        // Label as "Location" or "Dark mode"
        cell.settingText.text = settings[indexPath.row]
        
        // Put identifier on switch
        cell.settingsSwitch.restorationIdentifier = "\(settings[indexPath.row]) Identifier"
        
        // Set switch on/off
        if settings[indexPath.row] == "Dark Mode" {
            cell.settingsSwitch.isOn = curUser.value(forKey: "darkMode") as! Bool
        } else if settings[indexPath.row] == "Location" {
            cell.settingsSwitch.isOn = curUser.value(forKey: "location") as! Bool
        }
        
        return cell
    }
    
    // Change Core Data for setting that switch is associated with
    @IBAction func changeSwitch(_ sender: Any) {
        let selectedSwitch = sender as! UISwitch
        
        // Dark Mode switch
        if selectedSwitch.restorationIdentifier == "Dark Mode Identifier" {
            if selectedSwitch.isOn {
                print("Turned dark mode on")
                curUser.setValue(true, forKey: "darkMode")

                // Change all screens to dark mode
                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .dark
                }

            } else {
                print("Turned dark mode off")
                curUser.setValue(false, forKey: "darkMode")

                // CHange all screens to light mode
                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .light
                }

            }
        
        // Location setting
        } else if selectedSwitch.restorationIdentifier == "Location Identifier" {
            if selectedSwitch.isOn {
                print("Turned location on")
                
                // Set core data bool for location
                curUser.setValue(true, forKey: "location")

            } else {
                print("Turned location off")
                
                // Set core data bool for location
                curUser.setValue(false, forKey: "location")
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Save new value
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }

}
