//
//  TBSharedVC.swift
//  Tribe
//
//  Created by Ghost on 10/7/2017.
//  Copyright © 2017 Patrick. All rights reserved.
//

import UIKit

class TBSharedCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPlace: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnNavigate: UIButton!
    
    var shared: TBShared!
    var vc : UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewContainer.layer.cornerRadius = AppConsts.RADIUS_VIEW_CORNER
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewContainer.layer.shadowOpacity = 0.12
        viewContainer.layer.shadowRadius = 5.0
        btnShare.layer.cornerRadius = AppConsts.RADIUS_BUTTON_CORNER
        btnNavigate.layer.cornerRadius = AppConsts.RADIUS_BUTTON_CORNER
    }
    
    func setShared(shared: TBShared, vc:UIViewController) -> Void {
        self.shared = shared
        self.lblDate.text = AppConsts.strHistoryDate(date: shared.date)
        let placeName = shared.placeName ?? "\(shared.latitude), \(shared.longitude)"
        self.lblPlace.text = "You went to " + placeName
        
        if shared.isSharedByMe {
            self.lblDetail.text = NSLocalizedString("shared_yours", comment: "Your share")
        } else {
            self.lblDetail.text = NSLocalizedString("shared_others", comment: "Shared with you")
        }
        
        self.vc = vc
    }
    
    @IBAction func onClickShare(_ sender: Any) {
        let place = TBPlace()
        place.name = shared.placeName
        place.latitude = shared.latitude
        place.longitude = shared.longitude
        AppManager.sharePlace(place: place, vc: self.vc)
    }
    
    @IBAction func onClickNavigate(_ sender: Any) {
        let place = TBPlace()
        place.name = shared.placeName
        place.latitude = shared.latitude
        place.longitude = shared.longitude
        AppManager.navigatePlace(place: place)
    }
}

class TBSharedVC: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    
    var sharedLocations : [TBShared] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.estimatedRowHeight = 150
        tblView.rowHeight = UITableViewAutomaticDimension
        AppManager.sharedManager.sharedListener = self
        
        self.sharedLocations = AppManager.sharedManager.getSharedData()
        self.tblView.reloadData()
    }

}

extension TBSharedVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if sharedLocations.count > 0
        {
            numOfSections            = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = NSLocalizedString("shared_no_data", comment: "No Datas")
            noDataLabel.textColor     = AppConsts.COLOR_DARK_GRAY
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TBSharedCell = self.tblView.dequeueReusableCell(withIdentifier: "TBSharedCell") as! TBSharedCell
        if indexPath.row < sharedLocations.count {
            let shared = sharedLocations[indexPath.row]
            cell.setShared(shared: shared, vc: self)
        }
        return cell
    }
}

extension TBSharedVC: AppManagerSharedListener {
    func sharedUpdated() {
        self.sharedLocations = AppManager.sharedManager.getSharedData()
        self.tblView.reloadData()
    }
}
