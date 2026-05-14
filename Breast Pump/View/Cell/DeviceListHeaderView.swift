//
//  DeviceListHeaderView.swift
//  Breast Pump
//
//  Created by user on 2022/5/19.
//

import UIKit

// MARK: - Delegation
protocol DeviceListHeaderViewDelegate: AnyObject {
    func changeSideTapped()
}

class DeviceListHeaderView: UITableViewHeaderFooterView {
//    private var bleManager: BLEConnectionManager { BLEConnectionManager.shared }
    weak var delegate: DeviceListHeaderViewDelegate?
    
    @IBOutlet weak var changeSideButton: UIButton!
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) { // Drawing code }
    */
    
    
    @IBAction func changeSideTapped(_ sender: UIButton) {
//        print("changeSideTapped.")
        self.delegate?.changeSideTapped()
    }
    
}
