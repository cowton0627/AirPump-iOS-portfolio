//
//  PersonalPreferenceTableViewController.swift
//  Breast Pump
//
//  Created by user on 2022/3/28.
//

import UIKit
import AVFoundation

/// 個人化設定頁
class PersonalPreferenceTableViewController: UITableViewController {
    // MARK: - Properties
    private(set) var isBeepSwitchOn: Bool = false {
        didSet {
            rowHeightChangedWithAnimate()
        }
    }
    private(set) var isNotifySwitchOn: Bool = false {
        didSet {
            rowHeightChangedWithAnimate()
        }
    }
    // navigationBar用圖顯示原樣
    private let menuIcon = UIImage(systemName: "line.3.horizontal")
    
//    private let phoneBeepCellIndexPath    = IndexPath(row: 0, section: 0)
    private let leftBeepIndexPath     = IndexPath(row: 1, section: 0)
    private let rightBeepIndexPath    = IndexPath(row: 2, section: 0)
    private let beepIntervalIndexPath = IndexPath(row: 3, section: 0)
//    private let msgNotifyCellIndexPath    = IndexPath(row: 4, section: 0)
    private let leftNotifyIndexPath   = IndexPath(row: 5, section: 0)
    private let rightNotifyIndexPath  = IndexPath(row: 6, section: 0)
    
    private let systemGrayFive = #colorLiteral(red: 0.898, green: 0.8980392157, blue: 0.9176470588, alpha: 1)
    
    private let beepTimePickerView = UIPickerView()
    private let timeInterval = [ "5秒", "30分鐘", "1小時", "2小時", "6小時" ]
    
    // MARK: - IBOutlet
    @IBOutlet weak var beepTimeTextField: UITextField!
//    @IBOutlet weak var beepTimeTextField: CustomTextField!
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        configurePickerView()
        
//        beepTimeTextField.createDatePicker(target: self,
//                                           selector: #selector(doneTapped))
    }
    
    // MARK: - IBAction
    @IBAction func beepSwitchChanged(_ sender: UISwitch) {
        // sender與isBeepSwitchOn初值必需相同
        isBeepSwitchOn.toggle()
    }
    @IBAction func notifySwitchChanged(_ sender: UISwitch) {
        // sender與isNotifySwitchOn初值必需相同
        isNotifySwitchOn.toggle()
    }
    
    // MARK: - Methods
    private func configureUI() {
        view.backgroundColor = systemGrayFive

        // 設定navigationBar顯圖, 與buttonAction
        let leftBarItem = UIBarButtonItem(image: menuIcon, style: .plain, target: .none, action: nil)
        navigationItem.setLeftBarButton(leftBarItem, animated: true)
    }
    
    @objc func cancelTapped() {
        beepTimeTextField.resignFirstResponder()
    }
    
    @objc func doneTapped() {
//        if let datePicker = beepTimeTextField.inputView as? UIDatePicker {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "YYYY-MM-dd"
//            beepTimeTextField.text = dateFormatter.string(from: datePicker.date)
//        }
        
//        beepTimeTextField.text = beepTimePickerView.description

        beepTimeTextField.resignFirstResponder()
    }
    
    private func configurePickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                           target: nil, action: #selector(cancelTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: nil, action: #selector(doneTapped))
        toolBar.setItems([cancelButton, flexibleSpace, doneButton], animated: true)
        beepTimeTextField.inputAccessoryView = toolBar
        beepTimeTextField.inputView = beepTimePickerView
        beepTimePickerView.delegate = self
        beepTimePickerView.dataSource = self
    }
    
    private func rowHeightChangedWithAnimate() {
        /*
            調用這一套tableView的方法, 作用為改變列高自帶動畫, 不需reloadRow
            若在其中使用insert、delete、select、reloadRow則更smooth
         */
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: Delegate    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選取反白隨即消失
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath {
        case leftBeepIndexPath where isBeepSwitchOn == false: return 0
        case rightBeepIndexPath where isBeepSwitchOn == false: return 0
        case beepIntervalIndexPath where isBeepSwitchOn == false: return 0
        case leftNotifyIndexPath where isNotifySwitchOn == false: return 0
        case rightNotifyIndexPath where isNotifySwitchOn == false: return 0
        default:
            return UITableView.automaticDimension
        }
    }


}

extension PersonalPreferenceTableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return timeInterval.count
    }
    
}

extension PersonalPreferenceTableViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return timeInterval[row]
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {

        beepTimeTextField.text = timeInterval[row]
    }
    
}
