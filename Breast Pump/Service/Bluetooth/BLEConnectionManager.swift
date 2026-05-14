//
//  BLEConnectionManager.swift
//  Breast Pump
//
//  Created by Addwii on 2022/1/5.
//

import CoreBluetooth
import UIKit

/// 管理藍芽連接
class BLEConnectionManager: NSObject {
    /// 使用單例模式
    static let shared = BLEConnectionManager()
    
    /// 使用自訂 queue，避免多執行緒問題
    private let bleQueue = DispatchQueue(label: "bluetooth", qos: .userInitiated)

    /// CBCentralManager 物件，" 若 "使用 restore 選項，可在 App 被系統殺掉後自動恢復連線
    private lazy var manager = CBCentralManager(delegate: self, queue: bleQueue, options: [CBCentralManagerOptionRestoreIdentifierKey: "main"])

    private override init() {
        super.init()
        /*
           manager.delegate 應該不需在此處賦值, 否則失去 private lazy var 的作用,
           且沒有用到 delegate 的 func
         */
//        manager.delegate = self
    }
    
    /// 同一時間裝置連線上限
    private let deviceLimitCount = 2
    
    /// 掃描到的特徵，以 CBUUID 作為Key
    private(set) var charDict = [CBUUID: CBCharacteristic]()
    private(set) var charLastDict = [CBUUID: CBCharacteristic]()
    
    /// 已偵測裝置字典，以 UUIDString 作為Key
    private var scannedDeviceDict = [String: BLEDevice]()
    
    /// 連線中裝置字典，以 UUIDString 作為Key
    private var connectingDeviceDict = [String: BLEDevice]()
    
    /// 已連線裝置字典，以 UUIDString 作為Key
    private var connectedDeviceDict = [String: BLEDevice]()

    /// 已偵測的服務
//    private var restServices = [CBService]()
    /// 已連線且有模組型號的裝置字典，以 UUIDString 作為Key
//    var connectedIdentifiedDeviceDict: [String: BLEDevice] {
//        connectedDeviceDict.filter { $0.value.moduleType != nil }}
    /// 已連線且無模組型號的裝置字典，以 UUIDString 作為Key
//    var connectedUnidentifiedDeviceDict: [String: BLEDevice] {
//        connectedDeviceDict.filter { $0.value.moduleType == nil }}
    
}

// MARK: - Bluetooth
extension BLEConnectionManager {
    /// 藍芽是否開啟
    var isBluetoothOn: Bool { manager.state == .poweredOn }
    
    /// 藍芽狀態
    var bluetoothState: CBManagerState { manager.state }
    
    /// 已偵測裝置清單陣列（值由字典來，所以字典需做狀態處理）
    var scannedDevices: [BLEDevice] { Array(scannedDeviceDict.values) }

    /// 連線中裝置陣列
    var connectingDevices: [BLEDevice] { Array(connectingDeviceDict.values) }
    
    /// 已連線裝置陣列
    var connectedDevices: [BLEDevice] { Array(connectedDeviceDict.values) }
        
    /// 已連線且知道模組型號的裝置陣列
//    var connectedIdentifiedDevices: [BLEDevice] { Array(connectedIdentifiedDeviceDict.values) }

    /// 開始掃描
    func startingScan() {
        // MARK: <BLE步驟ㄧ 尋找裝置>
        guard manager.state == .poweredOn else { return }
        manager.scanForPeripherals(withServices: nil, options: nil)
        // 吸乳器service的uuid
//        let service = [GattAttributes.MACHINE_SERVICE]
//        manager.scanForPeripherals(withServices: service, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    /// 停止掃描
    func stopScanning() {
        // 注意！是在藍芽開啟狀態停止掃描
        guard manager.state == .poweredOn else { return }
        manager.stopScan()
    }
    
    /// 與裝置連線
    func connectDeviceActively(_ device: BLEDevice) {
        // 限制只能兩台連線(連線中+已連線)
        guard connectingDevices.count + connectedDevices.count < deviceLimitCount else { return }
        connect(device)
    }

    /// 與裝置斷開
    func disconnectDeviceActively(_ device: BLEDevice, completion: (()->())? = nil) {
        cancelConnection(peripheral: device.peripheral)
        // 斷線後的 Callback
//        disconnectCompletionList[device.peripheral.identifier.uuidString] = completion
    }
    
    /// 與裝置連線（內函數）
    private func connect(_ device: BLEDevice) {
        // FIXME: - bleQueue.async 似可拿掉, 因 manager 已預設在 bleQueue 中執行
        bleQueue.async { [self] in
            guard manager.state == .poweredOn else { return }
            // 連線中字典更新
            let peripheral = device.peripheral
            let uuidStr = peripheral.identifier.uuidString
            connectingDeviceDict[uuidStr] = device
            
            // MARK: 已偵測紀錄 - 裝置狀態從未連線 變成連線中
            // FIXME: 應該直接放值進去即可, 不需先移除值
            scannedDeviceDict.removeValue(forKey: uuidStr)
            scannedDeviceDict[uuidStr] = device
            
            manager.connect(peripheral, options: nil)
        }
    }
    
    /// 與裝置斷開（內函數）
    private func cancelConnection(peripheral: CBPeripheral) {
        // 裝置須為已連線或連線中
        guard peripheral.state == .connected || peripheral.state == .connecting else {
            // 否則手動呼叫 didDisconnectPeripheral 更新連線紀錄
            self.centralManager(manager, didDisconnectPeripheral: peripheral, error: nil)
            return
        }
        manager.cancelPeripheralConnection(peripheral)
    }

//    func startingScan(){
//        let queue = DispatchQueue.global()
//        self.centralManager = CBCentralManager(delegate: self, queue: queue)}
//    func stopScanning(){
//        self.centralManager.stopScan()}
//    func connectDevice(_ device: BLEDevice) {
//        let peripheral = device.peripheral
//        centralManager.connect(peripheral, options: nil)}
    
}

// MARK: - Notification Center
extension BLEConnectionManager {
    /// 廣播發現裝置，直接用參數device
    func broadcastDidDiscoverNewDevice(device: BLEDevice) {
        NotificationCenter.default.post(name: .didDiscoverDevice, object: nil,
                                        device: device)
    }
    /// 廣播裝置連線，直接用參數device
    func broadcastDidConnectedDevice(device: BLEDevice) {
        NotificationCenter.default.post(name: .didConnectedDevice, object: nil,
                                        device: device)
    }
    /// 廣播裝置斷線，直接用參數device
    func broadcastDidDisconnectDevice(device: BLEDevice) {
        NotificationCenter.default.post(name: .didDisconnectedDevice, object: nil,
                                        device: device)
    }
    /// 廣播藍芽關閉
    func broadcastDidTurnOffBluetooth() {
        NotificationCenter.default.post(name: .didTurnOffBluetooth, object: nil,
                                        userInfo: nil)
    }
    /// 廣播藍芽開啟
    func broadcastDidTurnOnBluetooth() {
        NotificationCenter.default.post(name: .didTurnOnBluetooth, object: nil,
                                        userInfo: nil)
    }
    /// 廣播CharDict變化
    func broadcastCharDictChanged() {
        NotificationCenter.default.post(name: .retrieveCharDict, object: nil,
                                        userInfo: ["charDict": charDict])
    }
    /// 廣播CharLastDict變化
    func broadcastCharLastDictChanged() {
        NotificationCenter.default.post(name: .retrieveCharLastDict, object: nil,
                                        userInfo: ["charLastDict": charLastDict])
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEConnectionManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // 檢查手機藍芽是否開啟
        switch central.state {
        case .poweredOn:
            broadcastDidTurnOnBluetooth()
//            if UserDefaultsConfig.isLoggedIn { tryToAutoConnect() } // 藍芽打開, 自動連線裝置
        case .poweredOff:
            broadcastDidTurnOffBluetooth()
            
            updateStateIfBLEPoweredOff()
            
        case .resetting:
            print("The connection with the BLE service was interrupted.")
        case .unauthorized:
            print("Must re-enable the permission to use BLE from the app’s Settings menu.")
        case .unsupported:
            print("The iOS device does not support BLE.")
        case .unknown:
            print("Unknown BLE service state.")
        default: break
        }
//        guard central.state == .poweredOn else { return }
//        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    /// 直接調整連線中、已連線裝置為未連線
    private func updateStateIfBLEPoweredOff() {
        // MARK: 已偵測紀錄 - 裝置狀態直接變成未連線
        for (uuidStr, _) in scannedDeviceDict {
            // FIXME: 寫法應該錯了, 因這樣寫是將移除的值再放回去
            let _device = scannedDeviceDict.removeValue(forKey: uuidStr)
            scannedDeviceDict[uuidStr] = _device
        }
        for (uuidStr, device) in connectingDeviceDict {
            connectingDeviceDict.removeValue(forKey: uuidStr)
            broadcastDidDisconnectDevice(device: device)
//            disconnectCompletionList.removeValue(forKey: key)
//            value.resetState()
        }
        for (uuidStr, device) in connectedDeviceDict {
            connectedDeviceDict.removeValue(forKey: uuidStr)
            broadcastDidDisconnectDevice(device: device)
//            disconnectCompletionList.removeValue(forKey: key)
//            value.resetState()
        }
    }
    
    // MARK: <BLE步驟二 找到裝置>
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        // 已連線裝置有兩台就不再掃描
        guard connectedDevices.count <= deviceLimitCount else {
            central.stopScan()
            return
        }
        
        guard peripheral.name != nil else { return }
        guard peripheral.name?.range(of: "F01") != nil else { return }
        let uuidStr = peripheral.identifier.uuidString
//        print("找到藍芽裝置：\(String(describing: peripheral.name))")
        #if DEBUG
        print("找到藍芽裝置：\(peripheral.name!)，裝置UUID: \(uuidStr)")
        #endif
        
        // 儲存裝置資訊（這步必須，否則裝置找到就消失）
        if let existedDevice = scannedDeviceDict[uuidStr] {
            // 記錄過的話, 就更新資訊
            existedDevice.rssi = RSSI.intValue
            existedDevice.advertisementData = advertisementData
        } else {
            // 未記錄的話, 就製造資訊
            let newDevice = BLEDevice(peripheral: peripheral,
                                      advertisementData: advertisementData,
                                      rssi: RSSI.intValue)
            scannedDeviceDict[uuidStr] = newDevice
            broadcastDidDiscoverNewDevice(device: newDevice)
        }
        
        // 一般藍芽流程
//        currentPeripheral = peripheral
//        currentPeripheral.delegate = self
//        central.stopScan()

    }

    // MARK: 處理連接（對單一裝置有可能被呼叫多次）
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        let uuidStr = peripheral.identifier.uuidString
        
        // 檢查是否記錄過, 避免因多次呼叫而多次記錄, 且以下皆避免
        guard let device = scannedDeviceDict[uuidStr],
              connectedDeviceDict[uuidStr] == nil else { return }
        
        // MARK: 已偵測紀錄 - 裝置狀態從連線中 變成已連線
        scannedDeviceDict.removeValue(forKey: uuidStr)
        scannedDeviceDict[uuidStr] = device
        
        // 紀錄從連線中 移動到 已連線
        connectingDeviceDict.removeValue(forKey: uuidStr)
        connectedDeviceDict[uuidStr] = device
        broadcastDidConnectedDevice(device: device)
        
        // 斷線後charArray要清空, 若擺在這表示連接後需先清空, 再放新的進去
//        charDict = [:]
//        charLastDict = [:]
        broadcastCharDictChanged()
        broadcastCharLastDictChanged()
        
        // 設定外部裝置的delegate
        peripheral.delegate = self
        // MARK: <BLE步驟四 尋找服務>
        peripheral.discoverServices([GATT.MACHINE_SERVICE,
                                     GATT.BATTERY_SERVICE,
//                                     GATT.FIRMWARE_VERSION
//                                     GATT.UUID_DEVICE_INFO,
//                                     GATT.UUID_CHARACTERISTIC_DESCRIPTION
                                    ]) // 第一順位不宜調換, 否則影響後面字典判斷流程
    }
    
    // MARK: 處理斷連
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        let uuidStr = peripheral.identifier.uuidString
        let deviceUUID = CBUUID(string: uuidStr)
        let device: BLEDevice
        
        // 已連線裝置先用charDict, 後用charLastDict
        // 哪個裝置斷連, 理應清空該裝置特徵字典, 但晚點清空可以做其他事
        if charDict.keys.contains(deviceUUID) {
            charDict = [:]
//            broadcastCharDictChanged()
        } else if charLastDict.keys.contains(deviceUUID) {
            charLastDict = [:]
//            broadcastCharLastDictChanged()
        }
        
        // MARK: 已偵測紀錄 - 裝置狀態從已連線 變成未連線
        // FIXME: 寫法應該錯了, 因這樣寫是將移除的值再放回去
        if let _device = scannedDeviceDict.removeValue(forKey: uuidStr) {
            scannedDeviceDict[uuidStr] = _device
        }
        
        // 從已連線 或 連線中清單移除, 留著 device 是為了廣播
        if let _device = connectedDeviceDict.removeValue(forKey: uuidStr) {
            device = _device
        } else if let _device = connectingDeviceDict.removeValue(forKey: uuidStr) {
            device = _device
        } else {
            // state應是disconnecting, 試發送斷線通知（似無用）
            print("Neither Connected nor Connecting State.")
            NotificationCenter.default.post(name: .didDisconnectedDevice,
                                            object: nil, userInfo: nil)
//            assertionFailure("Unknown Device")
            return
        }
        
        broadcastDidDisconnectDevice(device: device)
        
        // 有可能並非主動斷線，試著連線；如果沒有自動連線紀錄，就不會連線
//        if UserDefaultsConfig.isLoggedIn { tryToAutoConnect() }

    }
    
    // 處理連線失敗
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        cancelConnection(peripheral: peripheral)
    }
 
}

// MARK: - CBPeripheralDelegate
extension BLEConnectionManager: CBPeripheralDelegate {
    // 裝置下的服務
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        guard error == nil else {
            cancelConnection(peripheral: peripheral)
            return
        }
        guard let services = peripheral.services else {
            assertionFailure("peripheral.services should not be nil")
            cancelConnection(peripheral: peripheral)
            return
        }
        
        for service in services{
            print("藍芽裝置 \(peripheral.name!) 的服務UUID: \(service.uuid)")
            // MARK: <BLE步驟五 尋找特徵>
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    // 服務下的特徵
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard error == nil else {
            cancelConnection(peripheral: peripheral)
            return
        }
        guard service.characteristics != nil else {
            assertionFailure("service.characteristics should not be nil")
            cancelConnection(peripheral: peripheral)
            return
        }
        // MARK: <BLE步驟六 儲存特徵>
        let uuidStr = peripheral.identifier.uuidString
        let deviceUUID = CBUUID(string: uuidStr)
        
        if charDict.isEmpty && charLastDict.isEmpty { // 裝第一連線裝置的MACHINE_SERVICE用
            charDictValidate(peripheral, service: service)
            
        } else if !charDict.isEmpty && charLastDict.isEmpty {
            if !charDict.keys.contains(deviceUUID) { // 裝第二連線裝置的MACHINE_SERVICE用
                charLastDictValidate(peripheral, service: service)
                
            } else if charDict.keys.contains(deviceUUID) { // 裝第一連線裝置的BATTERY_SERVICE用
                charDictValidate(peripheral, service: service)
            }
            
        } else if charDict.isEmpty && !charLastDict.isEmpty {
            if !charLastDict.keys.contains(deviceUUID) { // 裝第二連線裝置的MACHINE_SERVICE用
                charDictValidate(peripheral, service: service)
                
            } else if charLastDict.keys.contains(deviceUUID) { // 裝第一連線裝置的BATTERY_SERVICE用
                charLastDictValidate(peripheral, service: service)
                
            }
        } else if !charDict.isEmpty && !charLastDict.isEmpty { // 裝第二連線裝置的BATTERY_SERVICE用
            if charDict.keys.contains(deviceUUID) { // 第一連線裝置斷連後, 重連變第二連線裝置
                charDictValidate(peripheral, service: service)
                
            } else if charLastDict.keys.contains(deviceUUID) {
                charLastDictValidate(peripheral, service: service)
                
            }
        }
   
        
    }
     
    private func charDictValidate(_ peripheral: CBPeripheral, service: CBService) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            let uuid = characteristic.uuid
            let uuidStr = uuid.uuidString
            print("\(peripheral.name!) 的特徵uuid：\(uuidStr)")
            
            charDict[uuid] = characteristic
            
            // 將裝置uuid作為字典重要key, 便可以uuid判斷要用哪個字典
            if uuid == GATT.DEVICE_UUID {
                charDict.removeValue(forKey: uuid)
                let deviceUUID = CBUUID(string: peripheral.identifier.uuidString)
                charDict[deviceUUID] = characteristic
            }
            // FIXME: 取用的特徵, 若已知要取用它的讀或寫, 就不用每個特徵都進到流程判斷
            if characteristic.properties.contains(.read) {
                // 此方法會一次性觸發didUpdateValueFor
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                // 此方法會多次性觸發didUpdateValueFor
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    private func charLastDictValidate(_ peripheral: CBPeripheral, service: CBService) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            let uuid = characteristic.uuid
            let uuidStr = uuid.uuidString
            print("\(peripheral.name) 其特徵 uuid：\(uuidStr)")
            
            charLastDict[uuid] = characteristic
            
            // 將裝置uuid作為字典重要key, 便可以uuid判斷要用哪個字典
            if uuid == GATT.DEVICE_UUID {
                charLastDict.removeValue(forKey: uuid)
                let deviceUUID = CBUUID(string: peripheral.identifier.uuidString)
                charLastDict[deviceUUID] = characteristic
            }
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    // 特徵值更新時
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard error == nil else {
            print("\(error?.localizedDescription)")
            return
        }
        // 濾掉液高以免訊息雜亂
        if characteristic.uuid != GATT.LIQUID_HEIGHT {
            // MARK: <BLE步驟七 特徵變化>
            print("更新 \(characteristic), 屬性: \(modifyPropertyRawValue(characteristic))\t, 值: \(characteristic.value?.first)\t/ \(characteristic.value!)")
        }
        
        if characteristic.uuid == GATT.DEVICE_UUID {
            print(characteristic)
        }
        
        // TODO: - 這邊應改成在其他特徵值更新時, 呼叫取回特徵值以更新液高, 以免液高不斷在更新
        // TODO: - 或是設定一段時間後才更新, 例如 15 秒
        guard let uuid = characteristic.service?.peripheral?.identifier.uuidString else {
            return
        }
        let deviceUUID = CBUUID(string: uuid)
        if charDict.keys.contains(deviceUUID) {
            broadcastCharDictChanged()
        } else if charLastDict.keys.contains(deviceUUID) {
            broadcastCharLastDictChanged()
        }
    }
    // 特徵值寫入時
    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard error == nil else {
            print("\(error?.localizedDescription)")
            return
        }
        print("===>\(characteristic)寫入成功")
    }
    
    /// 調整特徵特性的rawValue，液位、電量為18，isNotifying為26，isNotNotifying為2
    private func modifyPropertyRawValue(_ characteristic: CBCharacteristic) -> String {
        if characteristic.properties.rawValue.words.count == 1 {
            return " \(characteristic.properties.rawValue)"
        }
        return "\(characteristic.properties.rawValue)"
    }
    
    // 調整特徵字串顯示名稱
//    private func modifyGattString(_ characteristic: CBCharacteristic) -> String {
//        var wantedText = String()
//        switch characteristic.uuid {
//        case GATT.UUID_CHARACTERISTIC_DESCRIPTION:
//            wantedText = "UUID_CHARACTERISTIC_DESCRIPTION"
//        case GATT.BATTERY_SERVICE:
//            wantedText = "BATTERY_SERVICE"
//        case GATT.BATTERY_LEVEL:
//            wantedText = "BATTERY_LEVEL  "
//        case GATT.MACHINE_SERVICE:
//            wantedText = "MACHINE_SERVICE"
//        case GATT.MACHINE_STATUS:
//            wantedText = "MACHINE_STATUS "
//        case GATT.LIQUID_HEIGHT:
//            wantedText = "LIQUID_HEIGHT  "
//        case GATT.PUMP_STATUS:
//            wantedText = "PUMP_STATUS    "
//        case GATT.PUMP_LEVEL:
//            wantedText = "PUMP_LEVEL     "
//        case GATT.OPERATION_MODE:
//            wantedText = "OPERATION_MODE "
//        case GATT.BREAST_SIDE:
//            wantedText = "BREAST_SIDE    "
//        default:
//            wantedText = "               "
//        }
//        return wantedText
//    }
    
    // App被系統殺掉, 而因為藍芽偵測重新復活時會被呼叫
    func centralManager(_ central: CBCentralManager,
                        willRestoreState dict: [String : Any]) {
        // 檢查是否有復活的peripheral
        guard let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] else { return }

        for peripheral in peripherals {
            // 重新設定delegate
            peripheral.delegate = self
            let uuidStr = peripheral.identifier.uuidString
            let device = BLEDevice(peripheral: peripheral, advertisementData: [:], rssi: 0)
            // 恢復偵測紀錄
            if scannedDeviceDict[uuidStr] == nil {
                scannedDeviceDict[uuidStr] = device
            }

            // 此行錯誤, 復活時判定藍芽關閉
//            guard manager.state == .poweredOn else { continue }

            // 恢復連線相關紀錄（應主動重連）
            switch peripheral.state {
            case .connected:
                if connectedDeviceDict[uuidStr] == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                        self?.connectDeviceActively(device)
                    }
//                    centralManager(self.manager, didConnect: peripheral)
                }
            case .connecting:
                if connectingDeviceDict[uuidStr] == nil {
                    connectingDeviceDict[uuidStr] = device
                }
            default: break
            }
        }
    }
    
    
}

/// 調整特徵字串顯示名稱
extension CBCharacteristic {
    open override var description: String {
        switch self.uuid {
//        case GATT.UUID_CHARACTERISTIC_DESCRIPTION:
//            return "UUID_CHARACTERISTIC_DESCRIPTION"
//        case GATT.BATTERY_SERVICE:
//            return "BATTERY_SERVICE "
        case GATT.BATTERY_LEVEL:
            return "BATTERY_LEVEL   "
//        case GATT.MACHINE_SERVICE:
//            return "MACHINE_SERVICE "
        case GATT.MACHINE_STATUS:
            return "MACHINE_STATUS  "
        case GATT.LIQUID_HEIGHT:
            return "LIQUID_HEIGHT   "
        case GATT.PUMP_STATUS:
            return "PUMP_STATUS     "
        case GATT.PUMP_LEVEL:
            return "PUMP_LEVEL      "
        case GATT.OPERATION_MODE:
            return "OPERATION_MODE  "
        case GATT.BREAST_SIDE:
            return "BREAST_SIDE     "
        case GATT.DEVICE_UUID:
            return "DEVICE_UUID     "
        case GATT.ABC1, GATT.ABC2, GATT.ABC9, GATT.FFF0, GATT.FFE0, GATT.ABCA, GATT.FFE1, GATT.FFE2, GATT.ABCC, GATT.ABCD:
            return "                "
        default:
            return modifyDescription("\(self.uuid)")
        }
    }
    
    private func modifyDescription(_ uuid: String) -> String {
        if uuid == "System ID" {
            return "System ID       "
        } else if uuid == "Firmware Revision String" {
            return "Firmware Rev    "
        } else if uuid == "Hardware Revision String" {
            return "Hardware Rev    "
        } else if uuid == "Serial Number String" {
            return "Serial Number   "
        } else if uuid == "Manufacturer Name String" {
            return "ManufacturerName"
        }
        return     "                "
    }
    
}
