//
//  TodayTableViewCell.swift
//  Breast Pump
//
//  Created by Chunli Cheng on 2021/12/14.
//

import UIKit

class TodayTableViewCell: UITableViewCell {
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var leftAmountLabel: UILabel!
    @IBOutlet weak var leftDurationLabel: UILabel!
    @IBOutlet weak var rightAmountLabel: UILabel!
    @IBOutlet weak var rightDurationLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
