//
//  UITextField+Ext.swift
//  Breast Pump
//
//  Created by user on 2022/5/31.
//

import Foundation
import UIKit

extension UITextField {
    
    func createDatePicker(target: Any, selector: Selector) {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0,
                                                    width: screenWidth,
                                                    height: 216))
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "Chinese")
        // Added condition for iOS 14
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        self.inputView = datePicker
        
        // Create a toolbar and assign it to inputAccessoryView
        let toorbar = UIToolbar(frame: CGRect(x: 0, y: 0,
                                              width: screenWidth,
                                              height: 44))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                           target: nil,
                                           action: #selector(cancelTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: nil,
                                         action: selector)
        toorbar.setItems([cancelButton, flexibleSpace, doneButton], animated: true)
        self.inputAccessoryView = toorbar
    }
    
    @objc func cancelTapped() {
        self.resignFirstResponder()
    }
    
    func createPicker(target: Any, selector: Selector) {
        
    }
    
}
