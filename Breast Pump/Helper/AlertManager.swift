//
//  AlertManager.swift
//  Breast Pump
//
//  Created by user on 2022/5/19.
//

import UIKit

/// UIAlertManager and Toast Wrapper
/// - 可依照不同的方法，選用不同的 Alert
class AlertManager: NSObject {
    /// singleton，搭配 input alert 用，不必直接使用
    private static let shared = AlertManager()
    
    /// 對應 input alert 的 text field 跟 OK 按鈕
    private var inputDict = [UITextField: UIAlertAction]()
    
    private override init() { }
    
    /// 檢查 ok 按鈕是否該讓使用者可以按，如果使用者尚未打字則不能按
    @objc func checkValidityToEnableDoneBtn(_ sender: UITextField) {
        inputDict[sender]?.isEnabled = (sender.text?.trimmingCharacters(in: .whitespaces).count ?? 0) > 0
    }
    
    
    /// 顯示使用者能輸入文字內容的 Alert。
    ///  - Parameters:
    ///     - title: 訊息標題。
    ///     - subtitle: 訊息副標題。
    ///     - defaultText: 預設文字。
    ///     - placeholderText: placeholder 文字。
    ///     - emptyCheck: 輸入 true 來讓使用者至少要輸入一個文字才能按 OK。
    ///     - cancelText: 取消字樣。
    ///     - onCancel: 使用者按下取消後的 completion callback。
    ///     - confirmText: 執行動作的字樣。
    ///     - actionType: 動作種類。
    ///     - preferAction: 是否推薦執行該動作。
    ///     - onDone: 使用者按下確認後的 completion callback。
    static func showInputAlert(
        title: String,
        subtitle: String? = nil,
        defaultText: String? = nil,
        placeholderText: String? = nil,
        emptyCheck: Bool = true,
        cancelText: String = "",
        onCancel: ((UIAlertAction) -> ())? = nil,
        confirmText: String = "",
        actionType: UIAlertAction.Style,
        preferAction: Bool,
        onDone: @escaping ((_ doneAction: UIAlertAction, _ input: String?) -> ())
    ) {
        
        /// 清空 inputDict 紀錄，避免 retain
        func removeEmptyCheck(of action: UIAlertAction) {
            for(key, value) in Self.shared.inputDict {
                if value == action {
                    Self.shared.inputDict.removeValue(forKey: key)
                }
            }
        }
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.message = nil
        
        let ok = UIAlertAction(title: confirmText, style: actionType) { [weak alert] (action) in
            removeEmptyCheck(of: action)
            onDone(action, alert?.textFields?.first?.text)
        }
        
        alert.addTextField { (textField) in
            textField.clearButtonMode = .whileEditing
            textField.autocapitalizationType = .words
            textField.text = defaultText
            textField.placeholder = placeholderText
            
            // 如果要使用 emptyCheck，則每次使用者編輯都會更新 ok 按鈕的狀態，要有打字才能點選
            if emptyCheck {
                textField.addTarget(Self.shared,
                                    action: #selector(checkValidityToEnableDoneBtn(_:)),
                                    for: .editingChanged)
                textField.addTarget(Self.shared,
                                    action: #selector(checkValidityToEnableDoneBtn(_:)),
                                    for: .editingDidBegin)
                Self.shared.inputDict[textField] = ok
                Self.shared.checkValidityToEnableDoneBtn(textField)
            }
            
            let cancel = UIAlertAction(title: cancelText, style: .cancel) { (action) in
                
                if emptyCheck { removeEmptyCheck(of: ok) }
                onCancel?(action)
            }
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            if preferAction {
                alert.preferredAction = ok
            }
            
            Self.present(alert: alert, animated: true)
        }
    }
    
    /// 顯示只能按 OK 的 Alert。
    /// - Parameters:
    ///   - title: 標體。
    ///   - subtitle: 詳細訊息。
    ///   - confirmText: 確定按鈕字樣。預設為`確認`。
    ///   - onDone: 使用者按下 OK 後的 completion callback。
    static func showConfirmAlert(
        title: String,
        subtitle: String? = nil,
        confirmText: String = "確認",
        onDone: ((UIAlertAction) -> ())? = nil
    ) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            
        let ok = UIAlertAction(title: confirmText, style: .default, handler: onDone)
            
        alert.addAction(ok)
            
        Self.present(alert: alert, animated: true)
            
    }
    
    /// 讓使用者再次確認是否執行動作的 Alert。
    /// - Parameters:
    ///   - title: 訊息標題。
    ///   - subtitle: 訊息副標題。
    ///   - cancelText: 取消字樣。
    ///   - onCancel: 使用者按下取消後的 completion callback。
    ///   - confirmText: 執行動作的字樣。
    ///   - actionType: 動作種類。
    ///   - preferAction: 是否推薦執行該動作。
    ///   - onDone: 使用者按下確認行動後的 completion callback。
    static func showActionAlert(
        title: String? = "",
        subtitle: String? = nil,
        cancelText: String = "取消",
//    String = NSLocalizedString("text_button_cancel", comment: "")
        onCancel: ((UIAlertAction)->())? = nil,
        confirmText: String = "確認",
        actionType: UIAlertAction.Style,
        preferAction: Bool = false,
        onDone: ((UIAlertAction)->())?
    ) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: cancelText, style: .cancel, handler: onCancel)
        
        let ok = UIAlertAction(title: confirmText, style: actionType, handler: onDone)
        
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.preferredAction = preferAction ? ok : nil
        
        Self.present(alert: alert, animated: true)
    }
        
        
   
    
}

extension AlertManager {
    static private func present(alert: UIAlertController, animated: Bool, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIApplication.topViewController()?.present(alert, animated: animated,
                                                       completion: completion)
        }
    }
}

//// MARK: - Show Progress
//extension AlertManager {
//    static func showProgressOf(title: String, subtitle: String? = nil, progress: Progress, completion: ((UIAlertController) -> Void)? = nil) {
//
//    }
//
//
//}

extension UIApplication {
    /// 取得最底層的 VC
    class func rootViewController() -> UIViewController? {
        return UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
    }
    
    /// 取得最頂層的 VC
    class func topViewController(controller: UIViewController? = rootViewController()) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
