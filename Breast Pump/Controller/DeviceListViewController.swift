//
//  DeviceListViewController.swift
//  Breast Pump
//
//  Created by user on 2022/3/8.
//

import UIKit
import CoreBluetooth

/// 讓操作頁接值的協議
protocol DeviceListViewControllerDelegate: AnyObject {
    func sendDataToOperationVC()
}

/// 裝置頁
class DeviceListViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var deviceTableView: UITableView!
    
    // MARK: - Properties
    private var bleManager: BLEConnectionManager { BLEConnectionManager.shared }
    private var deviceList: [BLEDevice] { bleManager.scannedDevices }
//    private var stopwatch = Stopwatch()
//    private var stopLastWatch = Stopwatch()
    
//    private let alertView = ReusableAlertView.instantiateFromNib()
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: view.bounds)
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
    // 字串管理
    private let Left = "00"
    private let Right = "01"
    private let leftComment  = "-左"
    private let rightComment = "-右"
    private let Caution = "注意"
    private let PowerOrBLE = "請確認裝置電源或廣播已開啟"
    private let headerTitle = "名稱"
    
    private let headerHeight: CGFloat = 80
    
    /// 檢查 vc 是否有在畫面上，避免沒在畫面上做無謂的更新
    private var vcIsOnScreen: Bool {
        viewIfLoaded?.window != nil && UIApplication.shared.applicationState == .active
    }
    /// 警示次數限制
    private var alertCount: Int = 0
    /// 讓第一頁接值的代理
    weak var delegate: DeviceListViewControllerDelegate?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 為了不顯示多餘的分隔線（sectionTitle會消失）
//        deviceTableView.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        
        self.deviceTableView.register(viewWithClass: DeviceListHeaderView.self)
        
        // 關注裝置清單變化
        setupListener()
        // 更新列表
        configureList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bleManager.startingScan()
        checkIfDeviceIsReady()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 傳值回操作頁
        delegate?.sendDataToOperationVC()
        // 停止掃描
        bleManager.stopScanning()
    }
    
    // MARK: - Methods
    private func setupAlertView() {
        let alertView = ReusableAlertView.instantiateFromNib()
        alertView.delegate = self
        alertView.center = view.center
        alertView.setTitleLabel(title: "溫馨提醒", subtitle: "請檢查裝置電源或廣播",
                                lhsText: "確認", rhsText: nil)
        view.addSubview(backgroundView)
        view.addSubview(alertView)
    }
    
    /// 初進裝置頁時，裝置電源或廣播未開提示
    private func checkIfDeviceIsReady() {
        if bleManager.scannedDevices.count == 0, self.presentedViewController == nil {
//            AlertManager.showConfirmAlert(title: Caution,
//                                          subtitle: PowerOrBLE)
            setupAlertView()
        }
    }
    
    /// 檢查手機藍芽狀態，適當地跳出通知
    private func checkBLEState() {
        if bleManager.bluetoothState == .poweredOff, self.presentedViewController == nil {
//            AlertManager.showConfirmAlert(title: Caution,
//                                          subtitle: "請開啟藍芽")
            setupAlertView()
        }
    }
    
    private func configureList() {
        for device in deviceList {
            let uuid = CBUUID(string: device.peripheral.identifier.uuidString)
            
            if bleManager.charDict[uuid] != nil, let side = bleManager.charDict[GATT.BREAST_SIDE]?.value?.hexToStr() {
                device.deviceSide = side == Left ? leftComment : rightComment

            } else if bleManager.charLastDict[uuid] != nil, let side = bleManager.charLastDict[GATT.BREAST_SIDE]?.value?.hexToStr() {
                device.deviceSide = side == Left ? leftComment : rightComment

            }
        }
    }
    
    /// 裝置連線中，裝置電源或廣播未開提示
    private func checkDeviceIsReadyAgain() {
        // 因連線中會多次檢查, 故判斷是否有presented的VC再present, 並控制短時間present的次數
        if self.presentedViewController == nil, alertCount < 2 {
            AlertManager.showConfirmAlert(title: Caution,
                                          subtitle: PowerOrBLE) { [self] (_) in
                alertCount += 1
            }
//            let alert = UIAlertController(title: "注意",
//                                          message: "請確定裝置電源或廣播已開啟",
//                                          preferredStyle: .alert)
//            let action = UIAlertAction(title: "確定", style: .default) { [self] (_) in
//                alertCount += 1
//            }
//            alert.addAction(action)
//            present(alert, animated: true, completion: nil)
        }
    }
    
    /// 刷新裝置清單（參數暫無用）
    private func refresh(animated: Bool = true){
        deviceTableView.reloadData()
    }
    
    // 當BLEConnectionManager的特徵更新時, 更新列表裝置左右資訊
    @objc private func bleCharDictChanged() {
        for device in deviceList {
            let uuid = CBUUID(string: device.peripheral.identifier.uuidString)
            if bleManager.charDict[uuid] != nil,
                let side = bleManager.charDict[GATT.BREAST_SIDE]?.value?.hexToStr() {
                device.deviceSide = side == Left ? leftComment : rightComment

                DispatchQueue.main.async {
                    self.refresh()
                }
            }
        }
        
    }
    @objc private func bleCharLastDictChanged() {
        for device in deviceList {
            let uuid = CBUUID(string: device.peripheral.identifier.uuidString)
            if bleManager.charLastDict[uuid] != nil,
                let side = bleManager.charLastDict[GATT.BREAST_SIDE]?.value?.hexToStr() {
                device.deviceSide = side == Left ? leftComment : rightComment
                
                DispatchQueue.main.async {
                    self.refresh()
                }
            }
        }

    }
    
    /// 取出特徵字典裝置uuid
    private func deviceUUID(from dict: [CBUUID: CBCharacteristic]) -> String? {
        for (key, value) in dict {
            if value.uuid == GATT.DEVICE_UUID {
                let uuidStr = key.uuidString
                return uuidStr
            }
        }
        return nil
    }

}

// MARK: - TableViewDataSource
extension DeviceListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: DeviceListCell.self,for: indexPath)
        let device = deviceList[indexPath.row]
        // 為了不顯示多餘的分隔線
//        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        cell.configureCell(with: device)
        
        switch device.peripheral.state {
        case .connected:
            if let deviceSide = device.deviceSide {
                cell.connectionStateLabel.text = "已連線\(deviceSide)"
            } else {
                cell.connectionStateLabel.text = "已連線"
            }
//            alertCount = 0
        case .connecting:
            cell.connectionStateLabel.text = "連線中"

            checkDeviceIsReadyAgain()
            
        case .disconnected, .disconnecting:
            cell.connectionStateLabel.text = "未連線"

        @unknown default:
            cell.connectionStateLabel.text = "未知狀態"
        }
        return cell
    }
    
    
}

// MARK: - TableViewDelegate
extension DeviceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withClass: DeviceListHeaderView.self)
        headerView.delegate = self
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerHeight
    }
    // 為了在 iOS14 不顯示多餘的分隔線（其實會少一條）
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let device = deviceList[indexPath.row]
        
        switch device.peripheral.state {
        case .connected, .connecting:
            self.bleManager.disconnectDeviceActively(device, completion: nil)
            
        case .disconnected, .disconnecting:
            // MARK: <BLE步驟三 連接裝置>
            self.bleManager.connectDeviceActively(device)
            // 避免動畫閃太快
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                self.refresh()
            }
                
        @unknown default: fatalError()
        }
    }

}

// MARK: - Notification Center
private extension DeviceListViewController {
    /// 在適當時機刷新畫面
    func setupListener() {
        // 發現裝置
        NotificationCenter.default.addObserver(forName: .didDiscoverDevice, object: nil, queue: .main) { [weak self] (_) in self?.refresh() }
        
        // 取回特徵, 只為更新裝置左右資訊（相當於在連線中到已連線間的刷新）
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bleCharDictChanged),
                                               name: .retrieveCharDict, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bleCharLastDictChanged),
                                               name: .retrieveCharLastDict,
                                               object: nil)
        // 連線中
//        NotificationCenter.default.addObserver(forName: .didConnectingDevice, object: nil, queue: .main) { [weak self] (_) in self?.refresh(animated: true) }
        // 與裝置連線
//        NotificationCenter.default.addObserver(forName: .didConnectedDevice, object: nil, queue: .main) { [weak self] (_) in self?.refresh(animated: true) }
        
        // 與裝置斷線
        NotificationCenter.default.addObserver(forName: .didDisconnectedDevice, object: nil, queue: .main) { [weak self] (_) in self?.refresh() }
        
        // 藍芽關閉時, 跳出藍芽未開的警告
        NotificationCenter.default.addObserver(forName: .didTurnOffBluetooth, object: nil, queue: .main) { [weak self] (_) in self?.checkBLEState() }
        // 藍芽開啟時, 重啟掃描、更新 UI
        NotificationCenter.default.addObserver(forName: .didTurnOnBluetooth, object: nil, queue: .main) { [weak self] (_) in
            self?.bleManager.startingScan()
            // 不要太快更新自動連接清單, 避免快速閃現
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.refresh()
            }
        }
        
        // 進入背景時, 停止掃描以避免耗電
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] (_) in
             self?.bleManager.stopScanning()
         }
        // 回到前景時, 繼續掃描
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] (_) in
            guard let self = self, self.vcIsOnScreen else { return }
            self.bleManager.startingScan()
        }
    }
    
}

extension DeviceListViewController: DeviceListHeaderViewDelegate {
    /// 透過HeaderView切換設備左右
    func changeSideTapped() {
//        print("changeSideTapped.")
        guard bleManager.connectedDevices.count >= 1 else { return }
        
        if bleManager.charDict[GATT.BREAST_SIDE]?.value?.hexToStr() == Left {
            let uuid = deviceUUID(from: bleManager.charDict)
            
            let data = Data(hexString: Right)
            
            bleManager.connectedDevices.filter {
                $0.peripheral.identifier.uuidString == uuid
            }.first?.peripheral.writeValue(data!,
                                           for: bleManager.charDict[GATT.BREAST_SIDE]!,
                                           type: .withResponse)
            
        } else if bleManager.charDict[GATT.BREAST_SIDE]?.value?.hexToStr() == Right {
            let uuid = deviceUUID(from: bleManager.charDict)
            
            let data = Data(hexString: Left)
            
            bleManager.connectedDevices.filter {
                $0.peripheral.identifier.uuidString == uuid
            }.first?.peripheral.writeValue(data!,
                                           for: bleManager.charDict[GATT.BREAST_SIDE]!,
                                           type: .withResponse)
            
        }
    }
    
    
}

extension DeviceListViewController: ReusableAlertViewDelegate {
    func buttonTapped() {
        print("buttonTapped.")
        backgroundView.removeFromSuperview()
    }
    
    func lhsButtonTapped() {
        print("lhsButtonTapped.")
//        alertView.removeFromSuperview()
//        backgroundView.removeFromSuperview()
    }
    
    func rhsButtonTapped() {
        print("rhsButtonTapped.")
//        alertView.removeFromSuperview()
//        backgroundView.removeFromSuperview()
    }
}

