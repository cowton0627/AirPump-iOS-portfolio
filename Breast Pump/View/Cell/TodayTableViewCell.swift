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
        configureResponsiveLayout()
    }

    private func configureResponsiveLayout() {
        let detailLabels = [leftAmountLabel, leftDurationLabel,
                            rightAmountLabel, rightDurationLabel]
        detailLabels.forEach { label in
            label?.translatesAutoresizingMaskIntoConstraints = false
            label?.adjustsFontSizeToFitWidth = true
            label?.minimumScaleFactor = 0.75
            label?.lineBreakMode = .byClipping
        }

        NSLayoutConstraint.activate([
            leftAmountLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 8),
            leftAmountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
            leftDurationLabel.leadingAnchor.constraint(equalTo: leftAmountLabel.trailingAnchor, constant: 8),
            leftDurationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            leftDurationLabel.centerYAnchor.constraint(equalTo: leftAmountLabel.centerYAnchor),
            leftAmountLabel.widthAnchor.constraint(equalTo: leftDurationLabel.widthAnchor),

            rightAmountLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 8),
            rightAmountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 45),
            rightDurationLabel.leadingAnchor.constraint(equalTo: rightAmountLabel.trailingAnchor, constant: 8),
            rightDurationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightDurationLabel.centerYAnchor.constraint(equalTo: rightAmountLabel.centerYAnchor),
            rightAmountLabel.widthAnchor.constraint(equalTo: rightDurationLabel.widthAnchor),

            endTimeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.centerXAnchor, constant: -8),
            totalAmountLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.centerXAnchor, constant: -8)
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
