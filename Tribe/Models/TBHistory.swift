//
//  TBHistory.swift
//  Tribe
//
//  Created by Ghost on 16/7/2017.
//  Copyright © 2017 Patrick. All rights reserved.
//

import UIKit
import RealmSwift

class TBHistory: Object {

    dynamic var date:Date = Date()
    dynamic var latitude = 0.0, longitude = 0.0
    dynamic var placeName:String?
    dynamic var vicinity:String?
}
