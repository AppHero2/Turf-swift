//
//  TBSettingsVC.swift
//  Tribe
//
//  Created by Ghost on 10/7/2017.
//  Copyright © 2017 Patrick. All rights reserved.
//

import UIKit
import CoreLocation

class TBSettingsCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnSet: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnSet.layer.cornerRadius = AppConsts.RADIUS_BUTTON_CORNER
        viewContainer.layer.cornerRadius = AppConsts.RADIUS_VIEW_CORNER
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewContainer.layer.shadowOpacity = 0.12
        viewContainer.layer.shadowRadius = 5.0
    }
    
    @IBAction func onSet(_ sender: Any) {
        
    }
}

class TBSettingsVC: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    
    var isEnabledLocationService = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.estimatedRowHeight = 150
        tblView.rowHeight = UITableViewAutomaticDimension
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                isEnabledLocationService = false
            case .authorizedAlways, .authorizedWhenInUse:
                isEnabledLocationService = true
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
}

extension TBSettingsVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TBSettingsCell = self.tblView.dequeueReusableCell(withIdentifier: "TBSettingsCell") as! TBSettingsCell
        
        if indexPath.row < 2 {
            if indexPath.row == 0 {
                cell.lblTitle.text = NSLocalizedString("settings_location_services_title", comment: "")
                cell.lblDescription.text = NSLocalizedString("settings_location_services_descript", comment: "")
                cell.btnSet.setTitle(NSLocalizedString("settings_location_services_button0", comment: ""), for: .normal)
                cell.btnSet.addTarget(self, action: #selector(onClickLocationService), for: .touchUpInside)
                if isEnabledLocationService {
                    cell.btnSet.backgroundColor = AppConsts.COLOR_LIGHT_BLUE
                    cell.btnSet.setTitleColor(AppConsts.COLOR_TEXT_DARK_BLUE, for: .normal)
                    cell.btnSet.isEnabled = false
                } else {
                    cell.btnSet.backgroundColor = AppConsts.COLOR_LIGHT_GREEN
                    cell.btnSet.setTitleColor(AppConsts.COLOR_DARK_GREEN, for: .normal)
                    cell.btnSet.isEnabled = true
                }
                
            } else if indexPath.row == 1 {
                cell.lblTitle.text = NSLocalizedString("settings_location_history_title", comment: "")
                cell.lblDescription.text = NSLocalizedString("settings_location_hisotry_descript", comment: "")
                cell.btnSet.setTitle(NSLocalizedString("settings_location_history_button0", comment: ""), for: .normal)
                cell.btnSet.addTarget(self, action: #selector(onClickClearHistory), for: .touchUpInside)
                cell.btnSet.backgroundColor = AppConsts.COLOR_LIGHT_GREEN
                cell.btnSet.setTitleColor(AppConsts.COLOR_DARK_GREEN, for: .normal)
            }
        }
        
        return cell
    }
    
    func onClickLocationService() -> Void {
        //TODO: open settings
        guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            let alertController = UIAlertController(title: NSLocalizedString("settings_permission_title", comment: ""), message: NSLocalizedString("settings_permission_message", comment: ""), preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title:NSLocalizedString("settings_permission_go", comment: "Go"), style: .destructive) { action in
                UIApplication.shared.openURL(settingsURL)
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true){}
        }
    }
    
    func onClickClearHistory() -> Void {
        
        let alert = UIAlertController(title: NSLocalizedString("settings_history_alert_title", comment: "Are you sure?"),
                                      message: NSLocalizedString("settings_history_alert_msg", comment: ""),
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("settings_history_alert_no", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("settings_history_alert_yes", comment: ""), style: .default, handler: { (action) in
            AppManager.sharedManager.clearHistory()
            AppManager.sharedManager.clearShared()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
