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

class SuggestionsViewController: UIViewController, CLLocationManagerDelegate {
    var latitude = 0.0
    var longitude = 0.0

    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    var selectedUsers:[MateObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
        
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
                    if let array = value as? [[String : Any]] {
                        for dict in array {
                            guard
                                let business_status = dict["business_status"] as? String,
                                let name = dict["name"],
                                let rating = dict["rating"]
                                
                                else {
                                    print("Error parsing \(dict)")
                                    continue
                                }
                            
                            print(business_status, name, rating)
                        }
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

