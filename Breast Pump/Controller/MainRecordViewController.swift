//
//  MainRecordViewController.swift
//  Breast Pump
//
//  Created by Addwii on 2021/12/13.
//

import UIKit

/// 主紀錄頁
class MainRecordViewController: UIViewController {
    // MARK: - Properties
    private let screenHeight = UIScreen.main.bounds.height
    // navigationBar用圖顯示原樣
    private let prefMenuImage = UIImage(named: "prefMenu")?.withRenderingMode(.alwaysOriginal)
    private let selectedColor = #colorLiteral(red: 0.9803921569, green: 0.5960784314, blue: 0.5960784314, alpha: 1)
    private let idleColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
    private let customColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
    
    // MARK: - IBOutlet
    @IBOutlet var pageButtons: [UIButton]!
    @IBOutlet var recordViews: [UIView]!    
    
    // MARK: - IBAction
    @IBAction func todayPageTapped(_ sender: UIButton) {
        for recordView in recordViews {
            recordView.isHidden = true
        }
        recordViews[0].isHidden = false
        
        for pageButton in pageButtons {
            pageButton.backgroundColor = idleColor
            pageButton.setTitleColor(customColor, for: .normal)
        }
        pageButtons[0].backgroundColor = selectedColor
        pageButtons[0].setTitleColor(.white, for: .normal)
        
    }
    
    @IBAction func historyPageTapped(_ sender: UIButton) {
        for recordView in recordViews {
            recordView.isHidden = true
        }
        recordViews[1].isHidden = false
        
        for pageButton in pageButtons {
            pageButton.backgroundColor = idleColor
            pageButton.setTitleColor(customColor, for: .normal)
        }
        pageButtons[1].backgroundColor = selectedColor
        pageButtons[1].setTitleColor(.white, for: .normal)
        
    }
    
    @IBAction func analysisPageTapped(_ sender: UIButton) {
        for recordView in recordViews {
            recordView.isHidden = true
        }
        recordViews[2].isHidden = false
        
        for pageButton in pageButtons {
            pageButton.backgroundColor = idleColor
            pageButton.setTitleColor(customColor, for: .normal)
        }
        pageButtons[2].backgroundColor = selectedColor
        pageButtons[2].setTitleColor(.white, for: .normal)
        
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
//        self.tabBarItem.image = UIImage(systemName: "rectangle.3.offgrid.fill")
        
    }

    // MARK: - Methods
    private func configureUI() {
        // 設定navigationBar顯圖, 與buttonAction
        let leftBarItem = UIBarButtonItem(image: prefMenuImage, style: .plain, target: .none, action: nil)
        navigationItem.setLeftBarButton(leftBarItem, animated: true)

        for recordView in recordViews {
            recordView.isHidden = true
        }
        recordViews[0].isHidden = false
        
        for pageButton in pageButtons {
            pageButton.layer.cornerRadius = 25
            pageButton.backgroundColor = idleColor
            pageButton.setTitleColor(customColor, for: .normal)
        }
        pageButtons[0].backgroundColor = selectedColor
        pageButtons[0].setTitleColor(.white, for: .normal)
        
//        let buttonPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 120, height: 42), cornerRadius: 20)
//        let buttonShapeLayer1 = CAShapeLayer()
//        buttonShapeLayer1.path = buttonPath.cgPath
//        let buttonShapeLayer2 = CAShapeLayer()
//        buttonShapeLayer2.path = buttonPath.cgPath
//        let buttonShapeLayer3 = CAShapeLayer()
//        buttonShapeLayer3.path = buttonPath.cgPath
//        pageButtons[0].layer.mask = buttonShapeLayer1
//        pageButtons[1].layer.mask = buttonShapeLayer2
//        pageButtons[2].layer.mask = buttonShapeLayer3
        setupConstraint()
    }
    
    private func setupConstraint() {
        if screenHeight < 600 {
            for pageButton in pageButtons {
                pageButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                    .translatedBy(x: 0, y: 0)
            }
            for recordView in recordViews {
                recordView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                    .translatedBy(x: 0, y: 0)
            }
        }
    }
    

}
