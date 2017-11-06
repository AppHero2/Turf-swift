//
//  TBHomeVC.swift
//  Tribe
//
//  Created by Ghost on 10/7/2017.
//  Copyright © 2017 Patrick. All rights reserved.
//

import UIKit

import MapKit
import GooglePlacesAPI
import ObjectMapper
import Alamofire

class TBHomeVC: UIViewController {
    
    @IBOutlet weak var containerButtons: UIView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblMainTutor: UILabel!
    
    var popupController:CNPPopupController?
    
    fileprivate var isSearching: Bool = false
    fileprivate var isChangedQuery: Bool = false
    var arrPlaces : [TBNearBy] = []
    var searchKey : String = ""
    var txtSearch : UITextField?
    var tblView : UITableView?
    var topRefresher : PullToRefresh = PullToRefresh(height: 40, position: .top)
    
    var fingerIndicator : UIImageView?
    var fingerPlaceName : UILabel?
    var fingerDistance : UILabel?
    
    var selectedPlace : TBPlace?
    
    let locationDelegate = LocationDelegate()
    var latestLocation: CLLocation = CLLocation()
    var targetLocationBearing: CGFloat { return latestLocation.bearingToLocationRadian(self.targetLocation) }
    var targetLocation: CLLocation {
        get { return UserDefaults.standard.currentLocation }
        set { UserDefaults.standard.currentLocation = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerButtons.layer.cornerRadius = AppConsts.RADIUS_VIEW_CORNER
        // shadow
        containerButtons.layer.shadowColor = UIColor.black.cgColor
        containerButtons.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerButtons.layer.shadowOpacity = 0.12
        containerButtons.layer.shadowRadius = 5.0
        
        btnShare.layer.cornerRadius = AppConsts.RADIUS_BUTTON_CORNER
        btnSearch.layer.cornerRadius = AppConsts.RADIUS_BUTTON_CORNER
        lblDescription.text = NSLocalizedString("home_description", comment: "A shared location expires...")
        lblMainTutor.text = NSLocalizedString("home_main_tour", comment: "🔎😊...")
        
        GoogleMapsService.provide(apiKey: AppConsts.google_api_credential)
        
        AppManager.sharedManager.locationListener = self
        AppManager.sharedManager.navigateListener = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func onClickSearch(_ sender: Any) {
        let width = self.view.frame.size.width
        let searchBGView = UIView(frame: CGRect(x: 10, y: 10, width: width-20, height: 54))
        searchBGView.backgroundColor = AppConsts.COLOR_LIGHT_GRAY
        searchBGView.layer.cornerRadius = 5
        
        txtSearch = UITextField(frame: CGRect(x: 10, y: 9.5, width: width - 50, height: 35))
        txtSearch!.borderStyle = .none
        txtSearch!.returnKeyType = .search
        txtSearch!.autocorrectionType = .no
        txtSearch!.spellCheckingType = .no
        txtSearch!.textColor = AppConsts.COLOR_DARK_GRAY
        txtSearch!.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular)
        txtSearch!.placeholder = NSLocalizedString("home_search_placeholder", comment: "Search location")
        //txtSearch!.delegate = self
        txtSearch!.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchBGView.addSubview(txtSearch!)
        
        if tblView == nil {
            tblView = UITableView(frame: CGRect(x: 0, y: 0, width: width-20, height: width-100))
            tblView!.register(UINib(nibName: "TBHomeCell", bundle: nil), forCellReuseIdentifier: "TBHomeCell")
            tblView!.separatorColor = .clear
            tblView!.delegate = self
            tblView!.dataSource = self
            tblView!.addPullToRefresh(topRefresher) { [weak self] in
                self?.tblView!.endRefreshing(at: .top)
            }
        }
        
        let popupController = CNPPopupController(contents:[searchBGView, tblView!])
        popupController.theme = CNPPopupTheme.default()
        popupController.theme.popupStyle = .actionSheet
        popupController.theme.contentVerticalPadding = 16
        popupController.theme.movesAboveKeyboard = false
        popupController.theme.popupContentInsets = UIEdgeInsets(top: 16, left: 10, bottom: 210, right: 10)
        popupController.delegate = self
        self.popupController = popupController
        popupController.present(animated: true)
        
        txtSearch?.becomeFirstResponder()
    }
    
    @IBAction func onClickShare(_ sender: Any) {
        let width = self.view.frame.size.width
        let searchBGView = UIView(frame: CGRect(x: 10, y: 10, width: width-20, height: 50))
        searchBGView.backgroundColor = AppConsts.COLOR_LIGHT_GRAY
        searchBGView.layer.cornerRadius = 5
        
        let txtPlaceName = UITextField(frame: CGRect(x: 10, y: 7.5, width: width-40, height: 35))
        txtPlaceName.borderStyle = .none
        txtPlaceName.returnKeyType = .done
        txtPlaceName.autocorrectionType = .no
        txtPlaceName.spellCheckingType = .no
        txtPlaceName.textColor = AppConsts.COLOR_DARK_GRAY
        txtPlaceName.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular)
        txtPlaceName.delegate = self
        txtPlaceName.placeholder = NSLocalizedString("home_share_placeholder", comment: "What's the ...")
        searchBGView.addSubview(txtPlaceName)
        
        let lblDescription = UILabel(frame: CGRect(x: 10, y: 5, width: width - 40, height: 50))
        lblDescription.numberOfLines = 0
        lblDescription.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)
        lblDescription.textAlignment = .center
        lblDescription.textColor = AppConsts.COLOR_TEXT_DARK_BLUE
        lblDescription.text = NSLocalizedString("home_share_description", comment: "Users navigating...")
        
        /*let mapView = GMSMapView(frame: CGRect(x: 10, y: 5, width: width - 32, height: width-80))
        mapView.layer.cornerRadius = 5
        let currentPos = self.latestLocation.coordinate
        let camera = GMSCameraPosition.camera(withLatitude: currentPos.latitude, longitude: currentPos.longitude, zoom: 15.0)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        //mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true*/
        
        let mapView = MKMapView(frame: CGRect(x: 10, y: 5, width: width - 32, height: width*0.65))
        mapView.layer.cornerRadius = AppConsts.RADIUS_VIEW_CORNER
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        let coordinate = self.latestLocation.coordinate
        mapView.region = MKCoordinateRegionMakeWithDistance(coordinate, 1000.0, 1000.0)
        
        let containerButtons = UIView(frame: CGRect(x: 10, y: 10, width: width-32, height: 60))
        let buttonWidth = (width - 48) / 2
        let btnCancel = CNPPopupButton.init(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: 53))
        btnCancel.setTitleColor(AppConsts.COLOR_TEXT_DARK_BLUE, for: .normal)
        btnCancel.titleLabel?.font = AppConsts.FONT_BUTTON
        btnCancel.setTitle(NSLocalizedString("home_share_button_cancel", comment: "Cancel"), for: .normal)
        btnCancel.backgroundColor = AppConsts.COLOR_LIGHT_BLUE
        btnCancel.layer.cornerRadius = AppConsts.RADIUS_BUTTON_CORNER
        btnCancel.selectionHandler = { (button) -> Void in
            self.popupController?.dismiss(animated: true)
            self.arrPlaces.removeAll()
            self.tblView?.reloadData()
        }
        
        let btnShare = CNPPopupButton.init(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: 53))
        btnShare.setTitleColor(AppConsts.COLOR_DARK_GREEN, for: .normal)
        btnShare.titleLabel?.font = AppConsts.FONT_BUTTON
        btnShare.setTitle(NSLocalizedString("home_share_button_share", comment: "Share"), for: .normal)
        btnShare.backgroundColor = AppConsts.COLOR_LIGHT_GREEN
        btnShare.layer.cornerRadius = AppConsts.RADIUS_BUTTON_CORNER
        btnShare.selectionHandler = { (button) -> Void in
            let place = TBPlace()
            place.name = txtPlaceName.text
            place.latitude = self.latestLocation.coordinate.latitude
            place.longitude = self.latestLocation.coordinate.longitude
            AppManager.sharePlace(place: place, vc: self)
            
            self.popupController?.dismiss(animated: false)
        }
        
        containerButtons.addSubview(btnCancel)
        containerButtons.addSubview(btnShare)
        btnCancel.center = CGPoint.init(x: buttonWidth/2, y: btnCancel.center.y)
        btnShare.center = CGPoint.init(x: containerButtons.frame.size.width - buttonWidth/2, y: btnShare.center.y)
        
        let popupController = CNPPopupController(contents:[searchBGView, lblDescription, mapView, containerButtons])
        popupController.theme = CNPPopupTheme.default()
        popupController.theme.movesAboveKeyboard = false
        popupController.theme.popupStyle = .actionSheet
        popupController.theme.contentVerticalPadding = 16
        popupController.theme.popupContentInsets = UIEdgeInsets(top: 16, left: 10, bottom: 8, right: 10)
        popupController.delegate = self
        self.popupController = popupController
        popupController.present(animated: true)
    }
    
    func onClickPlace(place:TBNearBy) {
        
        selectedPlace = TBPlace()
        selectedPlace!.name = place.name
        selectedPlace!.vicinity = place.name
        selectedPlace!.latitude = place.latitude
        selectedPlace!.longitude = place.longitude
        selectedPlace!.distance = place.distance
        
        targetLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        
        self.onNavigatePlace(place: selectedPlace!)
    }
    
    func onNavigatePlace(place:TBPlace) -> Void {
        
        let history = TBHistory()
        history.date = Date()
        history.latitude = place.latitude
        history.longitude = place.longitude
        history.placeName = place.name
        history.vicinity = place.vicinity
        AppManager.sharedManager.addHistory(history: history)
        
        let width = self.view.frame.size.width
        let containView = UIView(frame: CGRect(x: 10, y: 10, width: width-20, height: width))
        
        fingerIndicator = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        fingerIndicator!.image = #imageLiteral(resourceName: "ic_finger")
        fingerIndicator!.contentMode = .scaleAspectFit
        fingerIndicator!.center = CGPoint(x: containView.center.x-10, y: containView.center.y - 65)
        containView.addSubview(fingerIndicator!)
        
        fingerPlaceName = UILabel(frame: CGRect(x: 0, y: width-95, width: width-20, height: 30))
        fingerPlaceName!.text = "📍" + (place.name ?? "\(history.latitude), \(history.longitude)")
        fingerPlaceName!.textColor = AppConsts.COLOR_TEXT_DARK_BLUE
        fingerPlaceName!.textAlignment = .center
        fingerPlaceName!.font = UIFont.systemFont(ofSize: 22, weight: UIFontWeightBold)
        containView.addSubview(fingerPlaceName!)
        
        fingerDistance = UILabel(frame: CGRect(x: 0, y: width-65, width: width-20, height: 30))
        fingerDistance!.text = String(format: "%.f", place.distance) + " Meters away"
        fingerDistance!.textColor = .black
        fingerDistance!.textAlignment = .center
        fingerDistance!.font = UIFont.systemFont(ofSize: 22, weight: UIFontWeightBold)
        containView.addSubview(fingerDistance!)
        
        let containerButtons = UIView(frame: CGRect(x: 10, y: 10, width: width-32, height: 60))
        let buttonWidth = (width - 48) / 2
        let btnCancel = CNPPopupButton.init(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: 53))
        btnCancel.setTitleColor(AppConsts.COLOR_TEXT_DARK_BLUE, for: .normal)
        btnCancel.titleLabel?.font = AppConsts.FONT_BUTTON
        btnCancel.setTitle(NSLocalizedString("home_share_button_cancel", comment: "Cancel"), for: .normal)
        btnCancel.backgroundColor = AppConsts.COLOR_LIGHT_BLUE
        btnCancel.layer.cornerRadius = AppConsts.RADIUS_BUTTON_CORNER
        btnCancel.selectionHandler = { (button) -> Void in
            self.popupController?.dismiss(animated: true)
            self.arrPlaces.removeAll()
            self.tblView?.reloadData()
        }
        
        let btnShare = CNPPopupButton.init(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: 53))
        btnShare.setTitleColor(AppConsts.COLOR_DARK_GREEN, for: .normal)
        btnShare.titleLabel?.font = AppConsts.FONT_BUTTON
        btnShare.setTitle(NSLocalizedString("home_share_button_share", comment: "Share"), for: .normal)
        btnShare.backgroundColor = AppConsts.COLOR_LIGHT_GREEN
        btnShare.layer.cornerRadius = AppConsts.RADIUS_BUTTON_CORNER
        btnShare.selectionHandler = { (button) -> Void in
            let place = TBPlace()
            place.name = self.selectedPlace?.name
            place.latitude = self.selectedPlace?.latitude
            place.longitude = self.selectedPlace?.longitude
            place.vicinity = self.selectedPlace?.vicinity
            AppManager.sharePlace(place: place, vc: self)
            
            self.popupController?.dismiss(animated: false)
        }
        
        containerButtons.addSubview(btnCancel)
        containerButtons.addSubview(btnShare)
        btnCancel.center = CGPoint(x: buttonWidth/2, y: btnCancel.center.y)
        btnShare.center = CGPoint(x: containerButtons.frame.size.width - buttonWidth/2, y: btnShare.center.y)
        
        let popupController = CNPPopupController(contents:[containView, containerButtons])
        popupController.theme = CNPPopupTheme.default()
        popupController.theme.movesAboveKeyboard = false
        popupController.theme.popupStyle = .actionSheet
        popupController.theme.contentVerticalPadding = 16
        popupController.theme.popupContentInsets = UIEdgeInsets(top: 16, left: 10, bottom: 8, right: 10)
        popupController.delegate = self
        self.popupController = popupController
        popupController.present(animated: true)
    }
}

extension TBHomeVC : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidChange(_ textField: UITextField) -> Void {
        searchKey = textField.text ?? ""
        isChangedQuery = true
        searchPlaces()
    }
    
    func searchPlaces() -> Void {
        if !isSearching {
            isSearching = true
            isChangedQuery = false
            arrPlaces.removeAll()
            tblView?.reloadData()
          
            self.tblView?.startRefreshing(at: .top)
            placeNearBy(forKeyword: searchKey, completion: { (places, error) in
                
                self.arrPlaces = places
                
                self.tblView?.reloadData()
                
                self.isSearching = false
                if self.isChangedQuery {
                    self.searchPlaces()
                } else {
                    self.tblView?.endRefreshing(at: .top)
                }
            })
        }
    }
    
    public func placeNearBy(forKeyword keyword: String, extensions: String? = nil, language: String? = nil, completion: ((_ places: [TBNearBy], _ error: NSError?) -> Void)?) {
        let currenPos = self.latestLocation.coordinate
        let placeDetailsURLString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        var requestParameters : [String:Any] = ["key" : AppConsts.google_api_credential,
                                 "location":"\(currenPos.latitude),\(currenPos.longitude)",
                                 "radius":50000,
                                 "keyword" : keyword]
        
        if let extensions = extensions {
            requestParameters["extensions"] = extensions
        }
        
        if let language = language {
            requestParameters["language"] = language
        }
        
        let request = Alamofire.request(placeDetailsURLString, method: .get, parameters: requestParameters).responseJSON { response in
            if response.result.isFailure {
                NSLog("Error: GET failed")
                completion?([], NSError(domain: "GooglePlacesError", code: -1, userInfo: nil))
                return
            }
            
            // Nil
            if let _ = response.result.value as? NSNull {
                completion?([], nil)
                return
            }
            
            // JSON
            guard let json = response.result.value as? [String : Any] else {
                NSLog("Error: Parsing json failed")
                completion?([], NSError(domain: "GooglePlacesError", code: -2, userInfo: nil))
                return
            }
            
            guard let results = json["results"] as? [Any] else {
                NSLog("Error: Parsing json failed")
                completion?([], NSError(domain: "GooglePlacesError", code: -2, userInfo: nil))
                return
            }
            
            var arrData : [TBNearBy] = []
            for result in results {
                let nearBy = TBNearBy(data: result as! [String : Any])
                arrData.append(nearBy)
            }
            
            arrData.sort(by: { (first, second) -> Bool in
                return first.distance < second.distance
            })
            
            completion?(arrData, nil)
            
        }
        
        debugPrint("\(request)")
    }
}

extension TBHomeVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TBHomeCell", for: indexPath) as! TBHomeCell
        if indexPath.row < arrPlaces.count {
            let place = arrPlaces[indexPath.row]
            cell.lblPlaceName.text = place.name
            cell.lblPlaceAddress.text = place.vicinity
            cell.lblDistance.text = String(format: "%.1f", place.distance/1000) + "km"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.popupController?.dismiss(animated: false)
        
        if indexPath.row < arrPlaces.count {
            let place = arrPlaces[indexPath.row]
            self.onClickPlace(place: place)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if arrPlaces.count > 0
        {
            numOfSections            = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = NSLocalizedString("home_no_places", comment: "No Results")
            noDataLabel.textColor     = AppConsts.COLOR_DARK_GRAY
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
        }
        return numOfSections
    }
}

extension TBHomeVC : CNPPopupControllerDelegate {
    
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        
    }
    
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        
    }
    
}

extension TBHomeVC : AppManagerNavigateListener {
    func navigatePlace(place: TBPlace) {
        selectedPlace = place
        targetLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        
        self.onNavigatePlace(place: place)
    }
}

extension TBHomeVC : AppManagerLocationListener {
    func locationUpdated(location: CLLocation) {
        self.latestLocation = location
        AppManager.sharedManager.currentLocation = location.coordinate
        
        let currenPos = self.latestLocation.coordinate
        if self.selectedPlace != nil {
            let coordinate₀ = CLLocation(latitude: currenPos.latitude, longitude: currenPos.longitude)
            let coordinate₁ = CLLocation(latitude: selectedPlace!.latitude, longitude: selectedPlace!.longitude)
            let distance = coordinate₀.distance(from: coordinate₁)// unit is meter
            self.fingerDistance?.text = String(format: "%.f", distance) + " Meters away"
        }
        
    }
    
    func headingUpdated(newHeading: CLLocationDirection) {
        func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
            let heading: CGFloat = {
                let originalHeading = self.targetLocationBearing - newAngle.degreesToRadians
                switch UIDevice.current.orientation {
                case .faceDown: return -originalHeading
                default: return originalHeading
                }
            }()
            
            return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
        }
        
        UIView.animate(withDuration: 0.5) {
            let angle = computeNewAngle(with: CGFloat(newHeading))
            self.fingerIndicator?.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    private func orientationAdjustment() -> CGFloat {
        let isFaceDown: Bool = {
            switch UIDevice.current.orientation {
            case .faceDown: return true
            default: return false
            }
        }()
        
        let adjAngle: CGFloat = {
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:  return 90
            case .landscapeRight: return -90
            case .portrait, .unknown: return 0
            case .portraitUpsideDown: return isFaceDown ? 180 : -180
            }
        }()
        return adjAngle
    }
}
