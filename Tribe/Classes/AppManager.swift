//
//  AppManager.swift
//  Vweeter
//
//  Created by Ghost on 7/10/2017.
//  Copyright © 2017 Ghost. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

protocol AppManagerLocationListener {
    func locationUpdated(location:CLLocation)
    func headingUpdated(newHeading:CLLocationDirection)
}

protocol AppManagerHistoryListener {
    func historyUpdated()
}

protocol AppManagerSharedListener {
    func sharedUpdated()
}

protocol AppManagerNavigateListener {
    func navigatePlace(place:TBPlace)
}

protocol AppManagerPageListener {
    func selectPageAt(index:Int)
}

class AppManager: NSObject {

    static let sharedManager = AppManager()
    
    let locationDelegate = LocationDelegate()
    let locationManager: CLLocationManager = {
        $0.requestWhenInUseAuthorization()
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingLocation()
        $0.startUpdatingHeading()
        return $0
    }(CLLocationManager())
    
    var currentLocation : CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var locationListener : AppManagerLocationListener?
    var historyListener : AppManagerHistoryListener?
    var sharedListener : AppManagerSharedListener?
    var navigateListener : AppManagerNavigateListener?
    var pageListener:AppManagerPageListener?
    
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        locationManager.delegate = locationDelegate
        
        locationDelegate.locationCallback = { location in
            self.locationListener?.locationUpdated(location: location)
        }
        
        locationDelegate.headingCallback = { newHeading in
            self.locationListener?.headingUpdated(newHeading: newHeading)
        }
    }
    
    func addHistory(history:TBHistory) -> Void {
        try! realm.write {
            realm.add(history)
        }
        
        self.historyListener?.historyUpdated()
    }
    
    func getHistoryData() -> [TBHistory] {
        var arrData : [TBHistory] = []
        let histories = realm.objects(TBHistory.self).sorted(byKeyPath: "date", ascending: false)
        for history in histories {
            arrData.append(history)
        }
        return arrData
    }
    
    func clearHistory() -> Void {
        let histories = realm.objects(TBHistory.self)
        for history in histories {
            try! realm.write {
                realm.delete(history)
            }
        }
        
        self.historyListener?.historyUpdated()
    }
    
    func addShared(shared:TBShared) -> Void {
        try! realm.write {
            realm.add(shared)
        }
        
        self.sharedListener?.sharedUpdated()
    }
    
    func getSharedData() -> [TBShared] {
        var arrData : [TBShared] = []
        let sharedData = realm.objects(TBShared.self).sorted(byKeyPath: "date", ascending: false)
        for shared in sharedData {
            arrData.append(shared)
        }
        return arrData
    }
    
    func deleteShared(shared:TBShared) -> Void {
        try! realm.write {
            realm.delete(shared)
        }
        
        self.sharedListener?.sharedUpdated()
    }
    
    func clearShared() -> Void {
        let sharedData = realm.objects(TBShared.self)
        for shared in sharedData {
            try! realm.write {
                realm.delete(shared)
            }
        }
        
        self.sharedListener?.sharedUpdated()
    }
    
    class func sharePlace(place:TBPlace, vc:UIViewController) {
        
        let subject = "Hello, Here is an awesome place."
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        let expireAt = Date().timeIntervalSince1970/1000 + 3600
        let stringURL : String = "myturf://share?by=\(uuid)&lat=\(place.latitude ?? 0.0)&lng=\(place.longitude ?? 0.0)&expireAt=\(expireAt)&place=\(place.name ?? "")"
        if let encoded = stringURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let url = URL(string: encoded)
        {
            let message = "Find me here on Turf \(url)"
            let objectsToShare = [message] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.setValue(subject, forKey: "Subject")
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            vc.present(activityVC, animated: true, completion: nil)
            
            activityVC.completionWithItemsHandler = { activity, success, items, error in
                if success == true {
                    let shared = TBShared()
                    shared.date = Date()
                    shared.latitude = place.latitude ?? 0.0
                    shared.longitude = place.longitude ?? 0.0
                    shared.placeName = place.name
                    shared.vicinity = place.vicinity
                    shared.link = url.absoluteString
                    shared.expireAt = expireAt
                    shared.isSharedByMe = true
                    AppManager.sharedManager.addShared(shared: shared)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        AppManager.sharedManager.pageListener?.selectPageAt(index: 2)
                    }
                }
            }
        }
        
    }
    
    class func navigatePlace(place:TBPlace){
        
        AppManager.sharedManager.pageListener?.selectPageAt(index: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AppManager.sharedManager.navigateListener?.navigatePlace(place: place)
        }
    }
}
