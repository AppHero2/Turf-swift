//
//  TBShared.swift
//  Tribe
//
//  Created by Ghost on 16/7/2017.
//  Copyright © 2017 Patrick. All rights reserved.
//

import UIKit
import RealmSwift

class TBShared: Object {
    dynamic var date:Date = Date()
    dynamic var latitude = 0.0, longitude = 0.0
    dynamic var placeName:String?
    dynamic var vicinity:String?
    dynamic var link:String = ""
    dynamic var isSharedByMe = false
    dynamic var expireAt:Double = Date().timeIntervalSince1970/1000 + 3600
}
