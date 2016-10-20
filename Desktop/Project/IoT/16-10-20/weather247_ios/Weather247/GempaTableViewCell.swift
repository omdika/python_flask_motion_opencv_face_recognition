//
//  GempaTableViewCell.swift
//  Weather247
//
//  Created by jogja247 on 10/11/16.
//  Copyright © 2016 Solusi247. All rights reserved.
//

import UIKit

class GempaTableViewCell: UITableViewCell {

    @IBOutlet weak var labelMagnitudo: UILabel!
    @IBOutlet weak var labelWaktu: UILabel!
    @IBOutlet weak var labelLokasi: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
