//
//  SuggestionsViewController.swift
//  Gourmate-iOS
//
//  Created by Matthew Onghai on 7/5/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class PlaceCell : UITableViewCell {
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var cuisineLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
}

class SuggestionsViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var latitude = 0.0
    var longitude = 0.0
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    var selectedUsers:[MateObject] = []
    var places:[[String : Any]] = []
    @IBOutlet weak var placesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        placesTableView.delegate = self
        placesTableView.dataSource = self
        placesTableView.rowHeight = 100;
        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.places.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func styleTableViewCell(cell:PlaceCell, place:[String:Any?], index:Int){
        cell.indexLabel.text = "\(index)"
        cell.placeNameLabel.text = place["name"] as? String
        cell.placeNameLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        cell.cuisineLabel.text = place["cuisine"] as? String
        cell.cuisineLabel.font = UIFont.italicSystemFont(ofSize: 12.0)
        
        cell.addressLabel.text = place["vicinity"] as? String
        
        
        cell.placeImageView.layer.borderWidth = 1
        cell.placeImageView.layer.masksToBounds = false
        cell.placeImageView.layer.borderColor = index % 2 == 0 ? UIColor.systemYellow.cgColor : UIColor.systemRed.cgColor
        cell.placeImageView.layer.cornerRadius = cell.placeImageView.frame.height/2
        cell.placeImageView.clipsToBounds = true
        
        let size:CGFloat = 20.0
        cell.indexLabel.textColor = UIColor.white
        cell.indexLabel.textAlignment = .center
        cell.indexLabel.font = UIFont.systemFont(ofSize: 14.0)
        cell.indexLabel.bounds = CGRect(x : 0.0,y : 0.0,width : size, height :  size)
        cell.indexLabel.layer.cornerRadius = size / 2
        cell.indexLabel.layer.borderWidth = 3.0
        let backgroundColor = index % 2 == 0 ? UIColor.systemYellow : UIColor.systemRed
        
        cell.indexLabel.layer.backgroundColor = backgroundColor.cgColor
        cell.indexLabel.layer.borderColor = backgroundColor.cgColor
        cell.indexLabel.layer.cornerRadius = 0.5 * cell.indexLabel.bounds.size.width
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceCell
        let source = self.places
        var place = source[indexPath.row]
        self.styleTableViewCell(cell: cell, place: place, index:indexPath.row+1)
        if place["imgObject"] != nil {
            cell.placeImageView.image = place["imgObject"] as? UIImage
        } else {
            let imageURL = URL(string: place["STORE_IMG"] as! String)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageURL!)
                place["imgObject"] = UIImage(data: data!)
                DispatchQueue.main.async {
                    cell.placeImageView.image = UIImage(data: data!)
                }
            }
        }
        return cell
    }
    
    
    func aggregateCuisines() -> Array<String>{
        var cuisines:Set = Set<String>()
        for user in selectedUsers {
            for cuisine in user.cuisines {
                cuisines.insert(cuisine)
            }
        }
        return Array(cuisines)
    }
    
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
    
    // Too much unused memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be created
    }
    
    // Change in location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Get location via Core Location
        let latestLocation:CLLocation = locations[locations.count - 1]
        latitude = latestLocation.coordinate.latitude
        longitude = latestLocation.coordinate.longitude
        
        print("Latitude: \(latitude), Longitude: \(longitude)")
        
        // Make API request on lodaing view
        if startLocation == nil {
            
            // Parameters for API call
            let parameters = [
                "location": ["latitude": latitude, "longitude": longitude, "radius": 500],
                "cuisines": self.aggregateCuisines(),
                "restrictions": self.aggregateRestrictions()
                ] as [String : Any]
            
            // Make API call
            AF.request("https://bagged-hockey-17985.herokuapp.com/api/search", method:.post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                
                switch response.result {
                case let .success(value):
                    print(value)
                    if var array = value as? [[String : Any]] {
                        self.places = array
                        for var place in self.places {
                            let imageURL = URL(string: place["STORE_IMG"] as! String)
                            DispatchQueue.global().async {
                                let data = try? Data(contentsOf: imageURL!)
                                DispatchQueue.main.async {
                                    place["imgObject"] = UIImage(data: data!)
                                }
                            }
                        }
                        //                        for dict in array {
                        //                            guard
                        //                                let business_status = dict["business_status"] as? String,
                        //                                let name = dict["name"],
                        //                                let rating = dict["rating"]
                        //
                        //                                else {
                        //                                    print("Error parsing \(dict)")
                        //                                    continue
                        //                                }
                        //                            print(business_status, name, rating)
                        //                        }
                        self.placesTableView.reloadData()
                    }
                    
                case let .failure(error):
                    print(error)
                }
            }
        }
        startLocation = latestLocation
    }
    
    // Send selected users to other screens
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupAnalysisSegue", let nextVC = segue.destination as?
            GroupAnalysisViewController {
            nextVC.selectedUsers = self.selectedUsers
        }
    }
}

