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
                    self.mates.append(MateObject(mateObj: child.value as! NSDictionary))
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
            return selected.count;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == allMatesTable {
            let user = self.searchActive ? filtered[indexPath.row] : mates[indexPath.row]
            if !selected.contains(user) {
                selected.append(user)
            }
            self.allMatesTable.deselectRow(at: indexPath, animated: true)
        } else {
            let user = selected[indexPath.row]
            if let index = selected.firstIndex(of: user) {
                selected.remove(at: index)
            }
        }
        
        self.selectedMatesTable.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mateCell", for: indexPath) as! MateCell
        let source = tableView == allMatesTable ? self.searchActive ? self.filtered : self.mates : selected;
        let mate = source[indexPath.row]
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
