//
//  SuggestionsViewController.swift
//  Gourmate-iOS
//
//  Created by Matthew Onghai on 7/5/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit
import Alamofire

class SuggestionsViewController: UIViewController {
    var selectedUsers:[MateObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parameters = [
            "location": ["latitude": 27.2308, "longitude": 77.5011, "radius": 300],
            "cuisines": self.aggregateCuisines(),
            "restrictions": self.aggregateRestrictions()
            ] as [String : Any]
        
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
    
}
