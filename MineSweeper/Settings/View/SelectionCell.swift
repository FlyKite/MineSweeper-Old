//
//  SelectionCell.swift
//  MineSweeper
//
//  Created by FlyKite on 2017/10/14.
//  Copyright © 2017年 Doge Studio. All rights reserved.
//

import UIKit

class SelectionCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
