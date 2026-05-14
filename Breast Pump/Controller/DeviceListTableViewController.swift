//
//  DeviceListTableViewController.swift
//  Breast Pump
//
//  Created by Chunli Cheng on 2022/1/24.
//

import UIKit
import CoreBluetooth

class DeviceListTableViewController: UITableViewController {
    // 紀錄 section 資訊
    // 分未連線、連線中(優先連線、自動連線)、已連線三種 section

//    private struct Section {
//        let headerName: String
//        var devicesUUID: [BLEDevice]
//        let type: BreastSide
//    }
//    private enum BreastSide: Int, CaseIterable {
//        case left  = 0
//        case right = 1
//        case none  = 2
//    }
    
    // MARK: - Properties
    private var bleManager: BLEConnectionManager { BLEConnectionManager.shared }
    /// 檢查 vc 是否有在畫面上，避免沒在畫面上做無謂的更新
    private var vcIsOnScreen: Bool { viewIfLoaded?.window != nil && UIApplication.shared.applicationState == .active }
    // 警示次數限制
    private var alertCount: Int = 0
//    var wantedStr = String()

    // 裝置的特徵值
//    private var charDict = [CBUUID: CBCharacteristic]()
//    private var charLastDict = [CBUUID: CBCharacteristic]()

//    private var sections = [Section]()
//    private var sectionState = [BreastSide: Section]()
//        [Section(headerName: "左乳裝置", devices: [BLEDevice](), type: .left),
//        Section(headerName: "右乳裝置", devices: [BLEDevice](), type: .right),
//        Section(headerName: "未連線裝置", devices: [BLEDevice](), type: .none)]
    

    /// 已連接且已經知道模組型號的裝置
//    private var connectedDevices: [String: BLEDevice] { bleManager.connectedIdentifiedDeviceDict }
    /// 已連接但尚未知道模組型號以及連接中裝置
//    private var connectingDevices: [String: BLEDevice] {
//        let connectedUnidentifiedDevicesDict = bleConnectionManager.connectedUnidentifiedDeviceDict
//        return bleConnectionManager.connectingDeviceDict.merging(connectedUnidentifiedDevicesDict) { (current, _) -> BLEDevice in current }
//    }
    
//    var device: CBPeripheral?
//    var chars = [CBCharacteristic]()
//    var deviceName: String?
//    var connectionState: String?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 設定關注連線裝置的數量變化
        setupListener()
        // 更新 UI
        refresh(animated: false)
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(retrieveCharDict(noti:)),
//                                               name: .retrieveCharDict, object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(retrieveCharLastDict(noti:)),
//                                               name: .retrieveCharDict, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bleManager.startingScan()
        // 初進入時未開電源或廣播提示
        if bleManager.scannedDevices.count == 0, self.presentedViewController == nil {
            let alert = UIAlertController(title: "注意", message: "請確定裝置電源或廣播已開啟", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
//        checkBLEState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        bleManager.stopScanning()
    }
    
    // MARK: - Methods
    // 檢查手機藍芽狀態
    private func checkBLEState() {
        if bleManager.bluetoothState == .poweredOff {
            let alert = UIAlertController(title: "注意", message: "請開啟藍芽", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(action)
            if self.presentedViewController == nil {
                present(alert, animated: true, completion: nil)
            }
        }
    }
    // 取回新特徵值
//    @objc private func retrieveCharDict(noti: Notification) {
//        if let userInfo = noti.userInfo,
//           let charDict = userInfo["charDict"] as? [CBUUID: CBCharacteristic] {
//            self.charDict = charDict
//        }
//    }
//    @objc private func retrieveCharLastDict(noti: Notification) {
//        if  let userInfo = noti.userInfo,
//            let charLastDict = userInfo["charLastDict"] as? [CBUUID: CBCharacteristic] {
//            self.charLastDict = charLastDict
//        }
//    }
  
    // MARK: - TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
//        sections.count
        return 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        sections[section].headerName
        return "名稱"
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        sections[section].devicesUUID.count
        return bleManager.scannedDevices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(DeviceListTableViewCell.self)", for: indexPath) as? DeviceListTableViewCell else {
            return UITableViewCell()
        }
        let device = bleManager.scannedDevices[indexPath.row]
        cell.deviceNameLabel.text = device.peripheral.name
        cell.deviceUUIDLabel.text = device.peripheral.identifier.uuidString
        
//        let device = sections[indexPath.section].devicesUUID[indexPath.row]
//        cell.deviceNameLabel.text = device.peripheral.name
//        cell.deviceUUIDLabel.text = device
        
        switch device.peripheral.state {
        case .connected:
            var wantedStr = String()
            let uuid = CBUUID(string: device.peripheral.identifier.uuidString)
            if bleManager.charDict[uuid] != nil, let charSide = bleManager.charDict[Gatt.BREAST_SIDE]?.value?.hexEncodedString() {
                charSide == "00" ? (wantedStr = "左") : (wantedStr = "右")
            }
            if bleManager.charLastDict[uuid] != nil, let charLastSide = bleManager.charLastDict[Gatt.BREAST_SIDE]?.value?.hexEncodedString() {
                charLastSide == "00" ? (wantedStr = "左") : (wantedStr = "右")
            }
            
            cell.connectionStateLabel.text = "已連線-\(wantedStr)"
            alertCount = 0
            // 此狀態沒有監聽, 必須重整
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        case .connecting:
            cell.connectionStateLabel.text = "連線中"
            let alert = UIAlertController(title: "注意", message: "請確定裝置電源或廣播已開啟", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default) { [self] (_) in
                alertCount += 1
            }
            alert.addAction(action)
            // 因連線中會多次檢查, 故判斷是否有presented的VC再present, 並控制短時間present的次數
            if self.presentedViewController == nil, alertCount < 2 {
                present(alert, animated: true, completion: nil)
            }
            // 此狀態沒有監聽, 必須重整
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        case .disconnected:
            cell.connectionStateLabel.text = "未連線"
        default:
            cell.connectionStateLabel.text = "未知狀態"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = bleManager.scannedDevices[indexPath.row]
//        let device = sections[indexPath.section].devices[indexPath.row]
        switch device.peripheral.state {
        //若主動斷線則刪除裝置所在位置
        case .connected, .connecting:
            self.bleManager.disconnectDeviceActively(device, completion: nil)
            
        case .disconnected:
            // MARK: <BLE步驟三 連接裝置>
            self.bleManager.connectDeviceActively(device)
            // 不要太快更新 (動畫會閃太快)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                self.refresh(animated: true)
            }
        
        default:
            self.bleManager.disconnectDeviceActively(device, completion: nil)
        }
    }

    
}

// MARK: - Notification Center
private extension DeviceListTableViewController {
    func setupListener() {
        // 在適當時機刷新畫面
        // 發現裝置
        NotificationCenter.default.addObserver(forName: .didDiscoverDevice, object: nil, queue: .main) { [weak self] (_) in self?.refresh(animated: true) }
        
        // 連線中
//        NotificationCenter.default.addObserver(forName: .didConnectingDevice, object: nil, queue: .main) { [weak self] (_) in self?.refresh(animated: true) }
        // 與裝置連線
//        NotificationCenter.default.addObserver(forName: .didConnectedDevice, object: nil, queue: .main) { [weak self] (_) in self?.refresh(animated: true) }
        
        // 與裝置斷線
        NotificationCenter.default.addObserver(forName: .didDisconnectedDevice, object: nil, queue: .main) { [weak self] (_) in self?.refresh(animated: true) }
        // 藍芽關閉時, 跳出藍芽未開的警告
        NotificationCenter.default.addObserver(forName: .didTurnOffBluetooth, object: nil, queue: .main) { [weak self] (_) in self?.checkBLEState() }
        // 藍芽開啟時, 重啟掃描、更新 UI
        NotificationCenter.default.addObserver(forName: .didTurnOnBluetooth, object: nil, queue: .main) { [weak self] (_) in
            self?.bleManager.startingScan()
            // 不要太快更新自動連接清單, 避免快速閃現
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.refresh(animated: true)
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

// MARK: - Private Function
private extension DeviceListTableViewController {
    // 刷新裝置清單
    func refresh(animated: Bool){
        tableView.reloadData()
        // 檢查藍芽裝置左右位置
        
//        let charSide = charDict[GattAttributes.BREAST_SIDE]?.value?.hexEncodedString()
//        let charLastSide = charLastDict[GattAttributes.BREAST_SIDE]?.value?.hexEncodedString()
//        let charDevice =
//            charDict.filter { $0.value == GattAttributes.DEVICE_UUID }.first?.key.uuidString
//        let charLastDevice =
//            charLastDict.filter { $0.value == GattAttributes.DEVICE_UUID }.first?.key.uuidString
//        var leftDevices = [BLEDevice]()
//        var rightDevices = [BLEDevice]()
//        if charSide == "00", let charDevice = charDevice {
//            leftDevices.append(charDevice)
//        } else if charSide == "01", let charDevice = charDevice {
//            rightDevices.append(charDevice) }
//        if charLastSide == "00", let charLastDevice = charLastDevice {
//            leftDevices.append(charLastDevice)
//        } else if charLastSide == "01", let charLastDevice = charLastDevice {
//            rightDevices.append(charLastDevice) }
//        var unconnectedDevices = [String]()
//        for device in bleManager.scannedDevices {
//            unconnectedDevices.append(device.peripheral.identifier.uuidString)
//        }
//        sections = [Section(headerName: "左乳裝置", devicesUUID: leftDevices, type: .left),
//            Section(headerName: "右乳裝置", devicesUUID: rightDevices, type: .right),
//            Section(headerName: "未連線裝置", devicesUUID: unconnectedDevices, type: .none)]
        
        // 假如有連線中裝置，則增加其Section
//            Array(self.bleManager.connectedDevices.values).sorted(by: \.name)
        // 假如有優先配對裝置，則增加其Section
//        let connectingDevicesArray = Array(self.connectingDevices.values).sorted(by: \.name)
//        sectionState[.right] = connectingDevicesArray.isEmpty ? nil : Section(headerName: ""), devices: connectingDevicesArray, type: .right)

//        sectionState[.none] =
//        sectionState[.right] =
//        sectionState[.left] =
        
//        if bleManager.scannedDevices.count == 2 {
//            if bleManager.charDict[GattAttributes.BREAST_SIDE]?.value?.hexEncodedString() == "00" {
//                bleManager.scannedDevices[0].peripheral
//            } else if bleManager.charDict[GattAttributes.BREAST_SIDE]?.value?.hexEncodedString() == "00" { }
//        } else if bleManager.scannedDevices.count == 1 {
//            if bleManager.charDict[GattAttributes.BREAST_SIDE]?.value?.hexEncodedString() == "00" {
//
//            } else if bleManager.charDict[GattAttributes.BREAST_SIDE]?.value?.hexEncodedString() == "00" { }
//        }
        
//        let initialSectionState = sectionState
//        sectionState[.unconnected] = unconnectedSection
//        updateSectionArray()
        
        // iOS 11 以上，使用動畫呈現列表更新
//        if animated, #available(iOS 11.0, *) {
//            self.tableView.performBatchUpdates({
//                var deleteIndexSet = IndexSet()
//                var insertIndexSet = IndexSet()
//                var reloadIndexSet = IndexSet()
//
//                for sectionType in SectionType.allCases {
//                    if initialSectionState[sectionType] != sectionState[sectionType] {
//                        if sectionState[sectionType] == nil {
//                            let indexSet = getSectionIndex(of: sectionType, in: initialSectionState)
//
//                            deleteIndexSet.insert(indexSet)
//                        } else if initialSectionState[sectionType] == nil {
//                            let indexSet = getSectionIndex(of: sectionType, in: sectionState)
//
//                            insertIndexSet.insert(indexSet)
//                        } else {
//                            let indexSet = getSectionIndex(of: sectionType, in: initialSectionState)
//
//                            reloadIndexSet.insert(indexSet)
//                        }
//                    }
//                }
//
//                if !deleteIndexSet.isEmpty { tableView.deleteSections(deleteIndexSet, with: .automatic) }
//                if !insertIndexSet.isEmpty { tableView.insertSections(insertIndexSet, with: .automatic) }
//                if !reloadIndexSet.isEmpty { tableView.reloadSections(reloadIndexSet, with: .automatic) }
//
//            }, completion: nil)
//        } else { tableView.reloadData() }
        
    }
    
    
//    // 更新section陣列
//    func updateSectionArray() {
//        self.sections = SectionType.allCases.compactMap { sectionState[$0] }
//    }
    
    // 回傳目前指定section的index，協助動畫實現
//    private func getSectionIndex(of sectionType: SectionType, in sectionState: [SectionType: Section]) -> Int {
//        switch sectionType {
//        case .connected:
//            return 0
//        case .connecting:
//            return sectionState[.connected] == nil ? 0 : 1
//        case .unconnected:
//            if sectionState[.connected] == nil, sectionState[.connecting] == nil {
//                return 0
//            } else if sectionState[.connected] != nil,  sectionState[.connecting] != nil {
//                return 2
//            } else {
//                return 1
//            }
//        }
//    }
    
}

