//
//  FiveLastTableViewCell.swift
//  Weather247
//
//  Created by jogja247 on 9/30/16.
//  Copyright © 2016 Solusi247. All rights reserved.
//

import UIKit

class FiveLastTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humLabel: UILabel!
    @IBOutlet weak var dpLabel: UILabel!
    @IBOutlet weak var apLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
