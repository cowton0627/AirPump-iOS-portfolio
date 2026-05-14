//
//  DiscussionViewController.swift
//  Breast Pump
//
//  Created by Addwii on 2022/2/25.
//

import UIKit

/// 討論區頁面
class DiscussionViewController: UIViewController {
    // MARK: - Properties
    // navigationBar用圖顯示原樣
    private let prefMenuImage = UIImage(named: "prefMenu")?.withRenderingMode(.alwaysOriginal)
    
//    private lazy var alertView: ReusableAlertView = {
//        let alertView = ReusableAlertView.instantiateFromNib()
//        alertView.delegate = self
//        return alertView
//    }()
//    private let alertView = ReusableAlertView.instantiateFromNib()
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: view.bounds)
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
//    private var vcIsOnScreen: Bool {
//        viewIfLoaded?.window != nil && UIApplication.shared.applicationState == .active }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if self.presentedViewController == nil {
//            AlertManager.showConfirmAlert(title: "", subtitle: "敬請期待")
//        }
        if self.presentedViewController == nil {
            showAlertView()
        }
//        let vc = UIStoryboard(name: .LowBatteryStoryboard).instantiateVC(withClass: LowBatteryAlertViewController.self)
//        vc.delegate = self
//        vc.modalTransitionStyle = .crossDissolve
//        vc.modalPresentationStyle = .overCurrentContext
//        present(vc, animated: true, completion: nil)
        
        
        
        
    }
    
    private func showAlertView() {
        let alertView = ReusableAlertView.instantiateFromNib()
        alertView.delegate = self
        alertView.center = view.center
        alertView.setTitleLabel(title: "溫馨提醒", subtitle: "敬請期待",
                                lhsText: "確認", rhsText: nil)
        view.addSubview(backgroundView)
        view.addSubview(alertView)
    }
    
    private func configureUI() {
        // 設定navigationBar顯圖, 與buttonAction
        let leftBarItem = UIBarButtonItem(image: prefMenuImage, style: .plain, target: .none, action: nil)
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
    func buttonTapped() {
        print("buttonTapped.")
        backgroundView.removeFromSuperview()
    }
    
    func lhsButtonTapped() {
        print("lhsButtonTapped.")
//        self.presentedViewController?.dismiss(animated: true)
//        alertView.removeFromSuperview()
//        backgroundView.removeFromSuperview()
    }
    
    func rhsButtonTapped() {
        print("rhsButtonTapped.")
//        alertView.removeFromSuperview()
//        backgroundView.removeFromSuperview()
    }
}

extension DiscussionViewController: LowBatteryAlertViewControllerDelegate {
    func confirmButtonTapped() {
        print("confirmButtonTapped.")
    }
    
    
}
