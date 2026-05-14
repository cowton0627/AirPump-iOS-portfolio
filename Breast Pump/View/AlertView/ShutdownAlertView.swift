//
//  ShutDownAlertView.swift
//  Breast Pump
//
//  Created by user on 2022/5/27.
//

import UIKit
import SwiftUI

// MARK: - Delegation
protocol ShutdownAlertViewDelegate: AnyObject {
    func buttonTapped(sender: ShutdownAlertView)
    func confirmTapped(sender: ShutdownAlertView)
}

/// 結束吸乳彈窗
class ShutdownAlertView: UIView {
    // MARK: - IBOutlet
    @IBOutlet weak var bottomView: CustomBottomView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    private let themeColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)
    private let titleColor = #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.4705882353, alpha: 1)
    
    weak var delegate: ShutdownAlertViewDelegate?
    
    class func instantiateFromNib() -> ShutdownAlertView {
        guard let view = UINib(nibName: "\(ShutdownAlertView.self)", bundle: nil)
                .instantiate(withOwner: nil, options: nil)[0] as? ShutdownAlertView else {
            return ShutdownAlertView()
        }
        view.configureUI()
        return view
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    @IBAction func confirmTapped(_ sender: UIButton) {
        print("confirmTapped.")
        self.delegate?.buttonTapped(sender: self)
        self.delegate?.confirmTapped(sender: self)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        print("cancelTapped.")
        self.delegate?.buttonTapped(sender: self)
    }
    
    
    @IBAction func closeTapped(_ sender: UIButton) {
        self.delegate?.buttonTapped(sender: self)
    }
    
    private func configureUI() {
        self.bottomView.layer.cornerRadius = 7
        self.bottomView.layer.borderWidth = 1
        self.bottomView.layer.borderColor = titleColor.cgColor
        self.closeButton.setTitle("", for: .normal)
        self.closeButton.setTitleColor(titleColor, for: .normal)
        self.closeButton.tintColor = themeColor
        self.closeButton.transform = CGAffineTransform(scaleX: 1.3,
                                                       y: 1.3)
        self.bottomView.layer.cornerRadius = 15
        self.confirmButton.backgroundColor = themeColor
        self.confirmButton.setTitleColor(.white, for: .normal)
        self.cancelButton.backgroundColor = themeColor
        self.cancelButton.setTitleColor(.white, for: .normal)
        self.confirmButton.layer.cornerRadius = 5
        self.cancelButton.layer.cornerRadius = 5
    }
    
    
    
    
}
