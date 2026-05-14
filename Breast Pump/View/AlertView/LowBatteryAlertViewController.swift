//
//  LowBatteryAlertViewController.swift
//  Breast Pump
//
//  Created by user on 2022/5/31.
//

import UIKit

// MARK: - Delegation
protocol LowBatteryAlertViewControllerDelegate: AnyObject {
    func confirmButtonTapped()
}

class LowBatteryAlertViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var bottomView: CustomBottomView!
    @IBOutlet weak var lowBatteryHintImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: - Properties
    private let themeColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)
    private let titleColor = #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.4705882353, alpha: 1)
    
    weak var delegate: LowBatteryAlertViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Methods
    private func configureUI() {
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
//        view.alpha = 0.5
        bottomView.layer.cornerRadius = 7
        bottomView.borderWidth = 1
        bottomView.borderColor = titleColor
        titleLabel.text = "請充電"
        titleLabel.textColor = .systemRed
        subtitleLabel.text = "以備下次使用"
        subtitleLabel.textColor = .systemRed
        confirmButton.backgroundColor = themeColor
        confirmButton.layer.cornerRadius = 5
        confirmButton.setTitle("知道了", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        defer { dismiss(animated: true, completion: nil) }
        self.delegate?.confirmButtonTapped()
    }
    

}
