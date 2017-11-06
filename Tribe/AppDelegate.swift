//
//  AppDelegate.swift
//  Tribe
//
//  Created by Mask on 7/7/17.
//  Copyright © 2017 Patrick. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey(AppConsts.google_api_credential)
        GMSPlacesClient.provideAPIKey(AppConsts.google_api_credential)
        
        _ = AppManager.sharedManager
        
        Thread.sleep(forTimeInterval: 1.5)//1.5 Delay Time
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if url.host == nil {
            return true
        }
        
        //TODO: show alert "are you sure"
        let urlString = url.absoluteString
        if urlString.range(of: "myturf://share?") != nil {
            var dict = [String:String]()
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            if let queryItems = components.queryItems {
                for item in queryItems {
                    dict[item.name] = item.value!
                }
            }
            
            let lat = Double(dict["lat"] ?? "0.0") ?? 0.0
            let lng = Double(dict["lng"] ?? "0.0") ?? 0.0
            let sharedBy = dict["by"]
            let placeName = dict["place"] ?? "\(lat),\(lng)"
            let expireAt = Double(dict["expireAt"] ?? "0") ?? Date().timeIntervalSince1970/1000
            
            let timeSince1970 = Date().timeIntervalSince1970/1000
            if expireAt < timeSince1970 {
                // expired
                let alertViewController = NYAlertViewController()
                alertViewController.addAction(NYAlertAction(title: NSLocalizedString("delegate_redirect_expired_ok", comment: ""), style: .default, handler: { (action) in
                    alertViewController.dismiss(animated: true, completion: nil)
                }))
                alertViewController.title = NSLocalizedString("delegate_redirect_expired_title", comment: "Is this ...")
                alertViewController.message =  NSLocalizedString("delegate_redirect_expired_msg", comment: "You've ...") + "\(placeName)" + "."
                self.window?.rootViewController?.present(alertViewController, animated: true, completion: nil)
            } else {
                let alertViewController = NYAlertViewController(nibName: nil, bundle: nil)
                alertViewController.addAction(NYAlertAction(title: NSLocalizedString("delegate_redirect_alert_no", comment: ""), style: .cancel, handler: { (action) in
                    alertViewController.dismiss(animated: true, completion: nil)
                }))
                alertViewController.addAction(NYAlertAction(title: NSLocalizedString("delegate_redirect_alert_yes", comment: ""), style: .default, handler: { (action) in
                    let shared = TBShared()
                    shared.date = Date(timeIntervalSince1970: TimeInterval((expireAt-3600)*1000))
                    shared.latitude = lat
                    shared.longitude = lng
                    shared.placeName = placeName
                    shared.link = urlString
                    shared.expireAt = expireAt
                    
                    let uuid = UIDevice.current.identifierForVendor!.uuidString
                    if uuid == sharedBy {
                        shared.isSharedByMe = true
                    } else {
                        shared.isSharedByMe = false
                    }
                    
                    AppManager.sharedManager.addShared(shared: shared)
                    
                    alertViewController.dismiss(animated: true, completion: {
                        let place = TBPlace()
                        place.name = shared.placeName
                        place.latitude = shared.latitude
                        place.longitude = shared.longitude
                        AppManager.navigatePlace(place: place)
                    })
                }))
                alertViewController.title = NSLocalizedString("delegate_redirect_alert_title", comment: "Is this ...")
                alertViewController.message =  NSLocalizedString("delegate_redirect_alert_msg", comment: "You've ...") + "\(placeName)" + "."
                
                let contentView = UIView(frame: .zero)
                let mapView = MKMapView(frame: .zero)
                mapView.translatesAutoresizingMaskIntoConstraints = false
                mapView.isZoomEnabled = false
                mapView.isScrollEnabled = false
                mapView.layer.cornerRadius = 6.0
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                mapView.region = MKCoordinateRegionMakeWithDistance(coordinate, 1000.0, 1000.0)
                
                /* annotation
                 let annotation = MKPointAnnotation()
                 annotation.coordinate = coordinate
                 mapView.addAnnotation(annotation)*/
                
                contentView.addSubview(mapView)
                
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mapView(160)]|",
                                                                          options: NSLayoutFormatOptions.init(rawValue: 0),
                                                                          metrics: nil,
                                                                          views: ["mapView":mapView]))
                
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[mapView]-|",
                                                                          options: NSLayoutFormatOptions.init(rawValue: 0),
                                                                          metrics: nil,
                                                                          views: ["mapView":mapView]))
                
                alertViewController.alertViewContentView = contentView;
                self.window?.rootViewController?.present(alertViewController, animated: true, completion: nil)
            }
            
        }
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
//        self.saveContext()
    }
    
    /*
    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Tribe")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
*/
}

