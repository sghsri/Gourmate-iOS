//
//  CreateGroupViewController.swift
//  Gourmate-iOS
//
//  Created by Sriram Hariharan on 7/5/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit
import FirebaseDatabase
// Cell in Dietary Restriction table
class MateCell : UITableViewCell {
    @IBOutlet weak var mateImage: UIImageView!
    @IBOutlet weak var mateName: UILabel!
}

class CreateGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive: Bool = false
    @IBOutlet weak var allMatesTable: UITableView!
    @IBOutlet weak var selectedMatesTable: UITableView!
    @IBOutlet weak var matesLabel: UILabel!
    var mates:[MateObject] = []
    var filtered:[MateObject] = []
    var selected:[MateObject] = []
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allMatesTable.delegate = self
        allMatesTable.dataSource = self
        selectedMatesTable.delegate = self
        selectedMatesTable.dataSource = self
        searchBar.delegate = self
        ref = Database.database().reference()
        self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for child in snapshots {
                    if let mate = child.value as? NSDictionary, curUserEmail != mate["email"] as? String {
                        self.mates.append(MateObject(mateObj: mate))
                    } else if let mate = child.value as? NSDictionary {
                        self.selected.append(MateObject(mateObj: mate))
                    }
                    self.filtered = self.mates
                }
                self.allMatesTable.reloadData()
            }
        })
        // Do any additional setup after loading the view.
    }
    
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = mates.filter({ (mate) -> Bool in
            let tmp: String = mate.name
            return tmp.hasPrefix(searchText)
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.allMatesTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == allMatesTable {
            if(searchActive) {
                return filtered.count
            }
            return mates.count;
        } else {
            return selected.count - 1;
        }
    }
    
    // Action for selecting row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Selecting on Mates table will move mate to selected group table
        print(selected)
        if tableView == allMatesTable {
            let user = self.searchActive ? filtered[indexPath.row] : mates[indexPath.row]
            if !selected.contains(user) {
                selected.append(user)
            }
            self.allMatesTable.deselectRow(at: indexPath, animated: true)
        // Selecting on Selected group table will move mate back
        } else {
            let user = selected[indexPath.row+1]
            if let index = selected.firstIndex(of: user) {
                let refreshAlert = UIAlertController(title: "Remove Mate", message: "Are you sure you want to remove this mate from your group?", preferredStyle: UIAlertController.Style.alert)

                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    self.selected.remove(at: index)
                    self.selectedMatesTable.reloadData()
                }))

                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                      print("Handle Cancel Logic here")
                }))

                present(refreshAlert, animated: true, completion: nil)
            }
        }
        self.selectedMatesTable.reloadData()
    }
    
    
    // Send selected users to other screens
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "makeGroupIdentifier", let nextVC = segue.destination as?
                   SuggestionsViewController {
                    nextVC.selectedUsers = self.selected
               }
        if segue.identifier == "groupAnalysisSegue", let nextVC = segue.destination as?
            GroupAnalysisViewController {
             nextVC.selectedUsers = self.selected
        }
    }
    
    // Data in the row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mateCell", for: indexPath) as! MateCell
        let source = tableView == allMatesTable ? self.searchActive ? self.filtered : self.mates : selected;
        let mate = source == selected ? source[indexPath.row + 1] : source[indexPath.row]
        cell.mateName.text = mate.name
        let imageURL = URL(string: mate.image)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: imageURL!)
            DispatchQueue.main.async {
                cell.mateImage.image = UIImage(data: data!)
            }
        }
        return cell
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
