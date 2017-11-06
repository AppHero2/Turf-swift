//
//  TBHomeCell.swift
//  Tribe
//
//  Created by Ghost on 13/7/2017.
//  Copyright © 2017 Patrick. All rights reserved.
//

import UIKit

class TBHomeCell: UITableViewCell {

    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var lblPlaceAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
