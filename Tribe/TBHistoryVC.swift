//
//  TBHistoryVC.swift
//  Tribe
//
//  Created by Ghost on 10/7/2017.
//  Copyright © 2017 Patrick. All rights reserved.
//

import UIKit

class TBHistoryCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPlace: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnNavigate: UIButton!
    
    var history:TBHistory!
    var vc:UIViewController!
    
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
    
    func setHistory(history:TBHistory, vc:UIViewController) -> Void {
        self.history = history
        
        self.lblDate.text = AppConsts.strHistoryDate(date: history.date)
        let placeName = history.placeName ?? "\(history.latitude), \(history.longitude)"
        self.lblPlace.text = "You went to " + placeName
        
        self.vc = vc;
    }
    
    @IBAction func onClickShare(_ sender: Any) {
        let place = TBPlace()
        place.name = history?.placeName
        place.latitude = history?.latitude
        place.longitude = history?.longitude
        AppManager.sharePlace(place: place, vc: self.vc)
    }
    
    @IBAction func onClickNavigate(_ sender: Any) {
        let place = TBPlace()
        place.name = history?.placeName
        place.latitude = history?.latitude
        place.longitude = history?.longitude
        AppManager.navigatePlace(place: place)
    }
}

class TBHistoryVC: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    var historyData:[TBHistory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.estimatedRowHeight = 150
        tblView.rowHeight = UITableViewAutomaticDimension
        AppManager.sharedManager.historyListener = self
        
        historyData = AppManager.sharedManager.getHistoryData()
        tblView.reloadData()
    }
    
}

extension TBHistoryVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if historyData.count > 0
        {
            numOfSections            = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = NSLocalizedString("history_no_data", comment: "No Histories")
            noDataLabel.textColor     = AppConsts.COLOR_DARK_GRAY
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TBHistoryCell = self.tblView.dequeueReusableCell(withIdentifier: "TBHistoryCell") as! TBHistoryCell
        if indexPath.row < historyData.count {
            let history = historyData[indexPath.row]
            cell.setHistory(history: history, vc: self)
        }
        return cell
    }
}

extension TBHistoryVC: AppManagerHistoryListener{
    func historyUpdated() {
        self.historyData = AppManager.sharedManager.getHistoryData()
        self.tblView.reloadData()
    }
}
