//
//  MateObject.swift
//  Gourmate-iOS
//
//  Created by Sriram Hariharan on 7/5/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import Foundation


class MateObject {
    var uID:String
    var email:String
    var name:String
    var givenName:String
    var image:String
    var cuisines:[String]
    var restrictions:[String]
    
    
    init(mateObj: NSDictionary) {
        self.uID = mateObj["uID"] as! String
        self.email = mateObj["email"] as! String
        self.name = mateObj["name"] as! String
        self.givenName = mateObj["givenName"] as! String
        self.image = mateObj["image"] as! String
        self.cuisines = mateObj["cuisines"] as! [String]
        self.restrictions = mateObj["restrictions"] as! [String]
    }
}
