//
//  SuggestionsViewController.swift
//  Gourmate-iOS
//
//  Created by Jennifer Suriadinata on 7/5/20.
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
    @IBOutlet weak var ratingLabel: UILabel!
}

class SuggestionsViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // Latitude and longitude of user
    var latitude = 0.0
    var longitude = 0.0

    // Core Location
    var locationManager:CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    var indicator = UIActivityIndicatorView()
    
    // Data from previous screen
    var selectedUsers:[MateObject] = []
    var radius = 500.0
    var places:[[String : Any]] = []
    var update = false
    
    @IBOutlet weak var placesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up suggestion table
        placesTableView.delegate = self
        placesTableView.dataSource = self
        placesTableView.rowHeight = 130;
        placesTableView.separatorColor = UIColor.clear
        placesTableView.layer.masksToBounds = true
        placesTableView.layer.borderColor = UIColor.systemYellow.cgColor
        placesTableView.layer.borderWidth = 4.0
        
        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Location on
        if curUser.value(forKey:"location") as! Bool {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        // Location off
        } else {
            locationManager.stopUpdatingLocation()
            
            // Default location is San Francisco, make API request immediately
            // This place was chosen because there are many places open nearby
            startLocation = CLLocation(latitude: 37.78, longitude: -122.40)
            latitude = startLocation.coordinate.latitude
            longitude = startLocation.coordinate.longitude
            print("Latitude: \(latitude), Longitude: \(longitude)")
            
            getSuggestions()
        }
        startLocation = CLLocation(latitude: 37.78, longitude: -122.40)
        update = true
        
    }
    
    // loading animation for the suggestions
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    // Number of rows for suggestions table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.places.count
    }
    
    // Selecting row will redirect to Google Maps location
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = self.places[indexPath.row]
        let location = (place["geometry"] as! NSDictionary)["location"] as! NSDictionary
        let url = "https://www.google.com/maps/@\(location["lat"] as! Double),\(location["lng"] as! Double),20z"
        
        UIApplication.shared.openURL(NSURL(string: url)! as URL)
    }
    
    // Styling for table
    func styleTableViewCell(cell:PlaceCell, place:[String:Any?], index:Int){
        
        cell.contentView.setCardView()
        
        // style the place label
        cell.placeNameLabel.text = place["name"] as? String
        cell.placeNameLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        cell.cuisineLabel.text = place["cuisine"] as? String
        cell.cuisineLabel.font = UIFont.italicSystemFont(ofSize: 12.0)
        
        cell.addressLabel.text = place["vicinity"] as? String
        
        // let's style the colors and the content of the image and ratings to be just like how we want them
        cell.ratingLabel.text = "\(place["rating"] as! Double) ⭑ (\(place["user_ratings_total"] as! Int) ratings)"
        cell.placeImageView.layer.borderWidth = 1
        cell.placeImageView.layer.masksToBounds = false
        cell.placeImageView.layer.borderColor = index % 2 == 0 ? UIColor.systemYellow.cgColor : UIColor.systemRed.cgColor
        cell.placeImageView.layer.cornerRadius = cell.placeImageView.frame.height/2
        cell.placeImageView.clipsToBounds = true
        cell.placeImageView.contentMode = .scaleToFill
        
        
        // show the index for every cell in a circle
        cell.indexLabel.text = "\(index)"
        
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
    
    // Data for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceCell
        let source = self.places
        var place = source[indexPath.row]
        self.styleTableViewCell(cell: cell, place: place, index:indexPath.row+1)
        if place["imgObject"] != nil {
            // if we've already loaded (chached) the UImage in the place object dictionary, then let's just use that
            cell.placeImageView.image = place["imgObject"] as? UIImage
        } else {
            // otherwise, let's fetch it and cache it now!
            if place["STORE_IMG"] != nil {
                let imageURL = URL(string: place["STORE_IMG"] as! String)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: imageURL!)
                    place["imgObject"] = UIImage(data: data!)
                    DispatchQueue.main.async {
                        cell.placeImageView.image = UIImage(data: data!)
                    }
                }
            }
        }
        return cell
    }
    
    // Get all cuisines
    func aggregateCuisines() -> Array<String>{
        var cuisines:Set = Set<String>()
        for user in selectedUsers {
            for cuisine in user.cuisines {
                cuisines.insert(cuisine)
            }
        }
        return Array(cuisines)
    }
    
    // Get all restrictions
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
    
    // Get suggestions with API request
    func getSuggestions(){
        activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = .white
        // Parameters for API call
        let parameters = [
            "location": ["latitude": latitude, "longitude": longitude, "radius": self.radius],
            "cuisines": self.aggregateCuisines(),
            "restrictions": self.aggregateRestrictions()
            ] as [String : Any]
        
        
        // Make API call with our location and cuisine information parameters
        AF.request("https://bagged-hockey-17985.herokuapp.com/api/search", method:.post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case let .success(value):
                // let as cast our JSON response as a dictionary of String keys to Any values
                if let array = value as? [[String : Any]] {
                    self.places = array
                    for var place in self.places {
                        // if the API provided a store image, let's load the URL and cache it
                        if place["STORE_IMG"] != nil {
                            let imageURL = URL(string: place["STORE_IMG"] as! String)
                            DispatchQueue.global().async {
                                let data = try? Data(contentsOf: imageURL!)
                                DispatchQueue.main.async {
                                    place["imgObject"] = UIImage(data: data!)
                                }
                            }
                        }
                    }
                    // stop the animation and reload the data with the new places
                    self.indicator.stopAnimating()
                    self.indicator.hidesWhenStopped = true
                    self.placesTableView.reloadData()
                }
                
            case let .failure(error):
                print(error)
            }
        }
    }
    
    // Change in location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Get location via Core Location
        let latestLocation:CLLocation = locations[locations.count - 1]
        latitude = latestLocation.coordinate.latitude
        longitude = latestLocation.coordinate.longitude
        
        print("Latitude: \(latitude), Longitude: \(longitude)")
        
        // Make API request on lodaing view
        if update {
            update = false
            getSuggestions()
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

// make a cardview view have dropshaddow and a lighter border
extension UIView {
    
    func setCardView(){
        layer.borderColor  =  UIColor.clear.cgColor
        layer.borderWidth = 5.0
        layer.shadowOpacity = 0.5
        layer.shadowColor =  UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width:5, height: 5)
        layer.masksToBounds = true
    }
}

