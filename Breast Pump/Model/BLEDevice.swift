//
//  BLEDevice.swift
//  Breast Pump
//
//  Created by Addwii on 2022/2/6.
//

import Foundation
import CoreBluetooth

/// BLE 裝置，記錄、處理連線資料。
class BLEDevice {
    // 連線資料
    let peripheral: CBPeripheral
    var advertisementData: [String : Any]
    var rssi: Int
    var deviceSide: String?
    
    init(peripheral: CBPeripheral,
         advertisementData: [String : Any],
         rssi: Int,
         deviceSide: String? = "") {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
        self.deviceSide = deviceSide
    }
    
    
}
