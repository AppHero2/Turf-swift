//
//  TBNearBy.swift
//  Tribe
//
//  Created by Ghost on 15/7/2017.
//  Copyright © 2017 Patrick. All rights reserved.
//

import UIKit
import CoreLocation

class TBNearBy: NSObject {
    var id, name, placeId, vicinity: String
    var latitude, longitude: Double
    var distance : Double
    
    init(data:[String:Any]) {
        self.id = data["id"] as! String
        self.name = data["name"] as! String
        self.placeId = data["place_id"] as! String
        self.vicinity = data["vicinity"] as? String ?? ""
        
        let geometry = data["geometry"] as! [String:Any]
        let location = geometry["location"] as! [String:Double]
        self.latitude = location["lat"] ?? 0.0
        self.longitude = location["lng"] ?? 0.0
        
        let currenPos = AppManager.sharedManager.currentLocation
        let coordinate₀ = CLLocation(latitude: currenPos.latitude, longitude: currenPos.longitude)
        let coordinate₁ = CLLocation(latitude: self.latitude, longitude: self.longitude)
        self.distance = coordinate₀.distance(from: coordinate₁)// unit is meter
    }
}
