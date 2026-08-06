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
        configureResponsiveLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func configureResponsiveLayout() {
        let labels = [endTimeLabel, totalAmountLabel, leftAmountLabel, leftDurationLabel,
                      rightAmountLabel, rightDurationLabel].compactMap { $0 }
        let legacyConstraints = contentView.constraints.filter { constraint in
            labels.contains { label in
                constraint.firstItem === label || constraint.secondItem === label
            }
        }
        NSLayoutConstraint.deactivate(legacyConstraints)

        let summaryStack = UIStackView(arrangedSubviews: [endTimeLabel, totalAmountLabel])
        summaryStack.axis = .vertical
        summaryStack.alignment = .leading
        summaryStack.spacing = 4

        let leftStack = UIStackView(arrangedSubviews: [leftAmountLabel, rightAmountLabel])
        let durationStack = UIStackView(arrangedSubviews: [leftDurationLabel, rightDurationLabel])
        [leftStack, durationStack].forEach {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.distribution = .fillEqually
            $0.spacing = 8
        }

        let detailStack = UIStackView(arrangedSubviews: [leftStack, durationStack])
        detailStack.axis = .horizontal
        detailStack.alignment = .fill
        detailStack.distribution = .fillEqually
        detailStack.spacing = 4

        [summaryStack, detailStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            summaryStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            summaryStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            summaryStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.42),

            detailStack.leadingAnchor.constraint(equalTo: summaryStack.trailingAnchor, constant: 4),
            detailStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            detailStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            detailStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
        ])

        labels.forEach {
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.75
            $0.lineBreakMode = .byClipping
        }
    }
}
