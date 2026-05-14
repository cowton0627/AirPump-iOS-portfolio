//
//  TodayViewController.swift
//  Breast Pump
//
//  Created by Addwii on 2021/12/13.
//

import UIKit
import RealmSwift

/// 今日紀錄
class TodayViewController: UIViewController {
    // MARK: - Properties
    private let screenHeight = UIScreen.main.bounds.height
    // MARK: - IBOutlet
    @IBOutlet weak var statisticTableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalAmountView: UIView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var leftAmountLabel: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var rightAmountLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    // constraint
    @IBOutlet weak var dateLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var totalAmountTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    // MARK: - Methods
    private func configureUI(){
        tabBarController?.tabBar.isTranslucent = false
        // 處理顯示日期
        let date = Date()
        let current = Calendar.current
        let year = current.component(.year, from: date)
        let day = current.component(.day, from: date)
        let month = current.component(.month, from: date)
        dateLabel.text = "\(year).\(month).\(day)"
        
        // 左view切成半圓
        let aDegree = CGFloat.pi / 180
        let leftPath = UIBezierPath(arcCenter: CGPoint(x: 145, y: 145),
                                    radius: 145,
                                    startAngle: aDegree * 90,
                                    endAngle: aDegree * 270, clockwise: true)
        let leftShapeLayer = CAShapeLayer()
        leftShapeLayer.path = leftPath.cgPath
        leftView.layer.mask = leftShapeLayer
        // 右view切成半圓
        let rightPath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 145),
                                     radius: 145,
                                     startAngle: -aDegree * 90,
                                     endAngle: aDegree * 90 , clockwise: true)
        let rightShapeLayer = CAShapeLayer()
        rightShapeLayer.path = rightPath.cgPath
        rightView.layer.mask = rightShapeLayer
        
        // 總量view呈圓形
        totalAmountView.layer.cornerRadius = 70
//        leftView.layer.maskedCorners = [.layerMinXMinYCorner ,.layerMinXMaxYCorner]
//        leftView.layer.cornerRadius = 145 / 2
//        rightView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
//        rightView.layer.cornerRadius = 145 / 2
        
//        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 140, height: 140))
//        let amountShapeLayer = CAShapeLayer()
//        amountShapeLayer.path = path.cgPath
//        totalAmountView.layer.mask = amountShapeLayer
        setupConstraints()
    }
    
    private func setupConstraints() {
        if screenHeight < 600 {
            dateLabelTopConstraint.constant = -50
            totalAmountTopConstraint.constant = -50
            stackViewTopConstraint.constant = -50
            tableViewTopConstraint.constant = -50
//            totalAmountView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
//                .translatedBy(x: 0, y: -25)
//            leftView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
//                .translatedBy(x: 25, y: -50)
//            rightView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
//                .translatedBy(x: -25, y: -50)
//            statisticTableView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75).translatedBy(x: 0, y: -50)
            
        }

    }
    

}

extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(TodayTableViewCell.self)", for: indexPath) as? TodayTableViewCell else {
//            return UITableViewCell()
//        }
        let cell = tableView.dequeueReusableCell(withClass: TodayTableViewCell.self, for: indexPath)
        
        cell.endTimeLabel.text = "下午 1:30"
        cell.totalAmountLabel.text = "140 mL"
        cell.leftAmountLabel.text = "左: 60 mL"
        cell.leftDurationLabel.text = "30 分鐘"
        cell.rightAmountLabel.text = "右: 80 mL"
        cell.rightDurationLabel.text = "35 分鐘"
        
        
        return cell
    }
    
    
}

extension TodayViewController: UITableViewDelegate {
    
}
