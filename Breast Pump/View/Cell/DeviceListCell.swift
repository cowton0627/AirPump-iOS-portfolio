//
//  DeviceListCell.swift
//  Breast Pump
//
//  Created by user on 2022/3/8.
//

import UIKit

class DeviceListCell: UITableViewCell {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceUUIDLabel: UILabel!
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var connectionStateLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var connectionStateTopConstraint: NSLayoutConstraint!
    private let screenHeight = UIScreen.main.bounds.height
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if screenHeight < 600 {
            connectionStateTopConstraint.constant = 16
            connectionStateLeadingConstraint.constant = -32
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(with data: BLEDevice) {
        deviceNameLabel.text = data.peripheral.name
        deviceUUIDLabel.text = data.peripheral.identifier.uuidString
        
    }

}
