//
//  HistoryTableViewCell.swift
//  Breast Pump
//
//  Created by user on 2022/3/21.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
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
