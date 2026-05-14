//
//  Notification+Ext.swift
//  Breast Pump
//
//  Created by Addwii on 2022/2/21.
//

import Foundation

extension Notification.Name {
    // 連接相關
    static let didDiscoverDevice = Notification.Name("didDiscoverDevice")
    static let didConnectingDevice = Notification.Name("didConnectingDevice") // 尚未使用到
    static let didConnectedDevice = Notification.Name("didConnectedDevice")
    static let didDisconnectedDevice = Notification.Name("didDisconnectedDevice")
    static let didTurnOnBluetooth = Notification.Name("didTurnOnBluetooth")
    static let didTurnOffBluetooth = Notification.Name("didTurnOffBluetooth")
    
    // 取回特徵
//    static let retrieveCharArr = Notification.Name("retrieveCharArr")
    static let retrieveCharDict = Notification.Name("retrieveCharDict")
    static let retrieveCharLastDict = Notification.Name("retrieveCharLastDict")
    
}

// 方便 post 時帶入資料
extension NotificationCenter {
    func post(name: Notification.Name, object: Any?, device: BLEDevice) {
        self.post(name: name, object: object, userInfo: ["BLEDevice": device])
    }
}

// 方便取得 noti 內資料（測試有crash可能, 暫不用）
extension Notification {
    var device: BLEDevice {
        self.userInfo!["BLEDevice"] as! BLEDevice
    }
}
