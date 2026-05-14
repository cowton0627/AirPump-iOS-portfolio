//
//  CustomTextField.swift
//  Breast Pump
//
//  Created by user on 2022/5/31.
//

import UIKit

// 暫時無用
class CustomTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) { // Drawing code }
    */
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
