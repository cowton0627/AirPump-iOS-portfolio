//
//  DiscussionViewController.swift
//  Breast Pump
//
//  Created by Chunli Cheng on 2022/2/25.
//

import UIKit

/// 討論區頁面
class DiscussionViewController: UIViewController {
    // MARK: - Properties
    private let menuIcon = UIImage(systemName: "line.3.horizontal")

    private weak var currentAlertView: ReusableAlertView?

    private lazy var backgroundView: UIView = {
        let view = UIView(frame: view.bounds)
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 切回此頁時，若 alert 已存在就不重複加入（避免疊加）
        guard presentedViewController == nil, currentAlertView == nil else { return }
        showAlertView()
    }

    private func showAlertView() {
        let alertView = ReusableAlertView.instantiateFromNib()
        alertView.delegate = self
        alertView.center = view.center
        alertView.setTitleLabel(title: "溫馨提醒", subtitle: "敬請期待",
                                lhsText: "確認", rhsText: nil)
        view.addSubview(backgroundView)
        view.addSubview(alertView)
        currentAlertView = alertView
    }
    
    private func configureUI() {
        // 設定navigationBar顯圖, 與buttonAction
        let leftBarItem = UIBarButtonItem(image: menuIcon, style: .plain, target: .none, action: nil)
        navigationItem.setLeftBarButton(leftBarItem, animated: true)
    }
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.        }
    */

}

// MARK: - ReusableAlertViewDelegate
extension DiscussionViewController: ReusableAlertViewDelegate {
    // ReusableAlertView 的 IBAction 會 defer removeFromSuperview()，
    // currentAlertView 是 weak ref，被釋放後會自動 nil。這裡只需處理 backgroundView。
    func buttonTapped() {
        backgroundView.removeFromSuperview()
    }

    func lhsButtonTapped() {}
    func rhsButtonTapped() {}
}

extension DiscussionViewController: LowBatteryAlertViewControllerDelegate {
    func confirmButtonTapped() {
        print("confirmButtonTapped.")
    }
    
    
}
