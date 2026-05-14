//
//  ReuseAlertView.swift
//  Breast Pump
//
//  Created by user on 2022/5/27.
//

import UIKit

// MARK: - Delegation
protocol ReusableAlertViewDelegate: AnyObject {
    func buttonTapped()
    func lhsButtonTapped()
    func rhsButtonTapped()
}

/// 可重用的警示彈窗
class ReusableAlertView: UIView {
    // MARK: - IBOutlet
    @IBOutlet weak var bottomView: CustomBottomView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var lhsButton: UIButton!
    @IBOutlet weak var rhsButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!    // 暫無用
    @IBOutlet weak var dividerView: UIView!
    
    // MARK: - Properties
    private let themeColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)
    private let titleColor = #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.4705882353, alpha: 1)
    
    weak var delegate: ReusableAlertViewDelegate?

    // MARK: - class func
    class func instantiateFromNib() -> ReusableAlertView {
        guard let view = UINib(nibName: "\(ReusableAlertView.self)", bundle: nil)
                .instantiate(withOwner: nil, options: nil)[0] as? ReusableAlertView else {
            return ReusableAlertView()
        }
        view.configureUI()
        return view
    }
    
    // MARK: - Methods
    /// 任一Button沒有title，表示沒有Button。
    func setTitleLabel(title: String? = nil,
                       subtitle: String? = nil,
                       lhsText: String? = "確認",
                       rhsText: String? = "取消") {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        
        if lhsText != nil {
            self.lhsButton.setTitle(lhsText, for: .normal)
        } else {
            lhsButton.removeFromSuperview()
        }
        if rhsText != nil {
            self.rhsButton.setTitle(rhsText, for: .normal)
        } else {
            rhsButton.removeFromSuperview()
        }
        if lhsText == nil || rhsText == nil {
            dividerView.removeFromSuperview()
        }
    }
    
    private func configureUI() {
        self.bottomView.layer.cornerRadius = 7
        self.bottomView.layer.borderWidth = 1
        self.bottomView.layer.borderColor = titleColor.cgColor
        self.titleLabel.textColor = titleColor
        self.subtitleLabel.textColor = titleColor
        self.lhsButton.backgroundColor = themeColor
        self.lhsButton.setTitleColor(.white, for: .normal)
        self.rhsButton.backgroundColor = themeColor
        self.rhsButton.setTitleColor(.white, for: .normal)
        self.lhsButton.layer.cornerRadius = 5
        self.rhsButton.layer.cornerRadius = 5
    }
    
    // MARK: - IBAction
    @IBAction func lhsButtonTapped(_ sender: UIButton) {
        defer { removeFromSuperview() }
        self.delegate?.buttonTapped()
        self.delegate?.lhsButtonTapped()
    }
    
    @IBAction func rhsButtonTapped(_ sender: UIButton) {
        defer { removeFromSuperview() }
        self.delegate?.buttonTapped()
        self.delegate?.rhsButtonTapped()
    }
    
}
