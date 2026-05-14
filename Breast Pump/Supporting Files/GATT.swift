//
//  GattAttributes.swift
//  Breast Pump
//
//  Created by Addwii on 2022/1/24.
//

import Foundation
import CoreBluetooth

/// 產品UUID
struct GATT {

    ///NOTIFICATION，目前無值
    static let UUID_CHARACTERISTIC_DESCRIPTION = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
    ///DEVICE INFORMATION SERVICE，目前無值
    static let UUID_DEVICE_INFO = CBUUID(string: "0000180a-0000-1000-8000-00805f9b34fb")
    
    /// 韌體特徵（非服務）
    static let FIRMWARE_VERSION  = CBUUID(string: "00002a26-0000-1000-8000-00805f9b34fb")
    
    /// 電池服務（UUID: Battery）
    static let BATTERY_SERVICE   = CBUUID(string: "0000180F-0000-1000-8000-00805f9b34fb")
    /// 電量數值
    static let BATTERY_LEVEL     = CBUUID(string: "00002A19-0000-1000-8000-00805f9b34fb")
    
    /// 裝置服務
    static let MACHINE_SERVICE   = CBUUID(string: "0000ABC0-0C0B-0A09-0807-060504030201")
    // 機器狀態（ 0代表正常 / 其他為異常 )
    static let MACHINE_STATUS    = CBUUID(string: "0000ABC3-0C0B-0A09-0807-060504030201")
    // 液體位置（ 高度數值 ）
    static let LIQUID_HEIGHT     = CBUUID(string: "0000ABC4-0C0B-0A09-0807-060504030201")
    // PUMP狀態（ 0代表暫停 / 1代表啟動 ）
    static let PUMP_STATUS       = CBUUID(string: "0000ABC5-0C0B-0A09-0807-060504030201")
    // 力道增減（ 填入數值，0~8 ）
    static let PUMP_LEVEL        = CBUUID(string: "0000ABC6-0C0B-0A09-0807-060504030201")
    // 操作模式（ 自動模式為兩分鐘後切換 / 1為擠乳模式 / 0為按摩模式）
    static let OPERATION_MODE    = CBUUID(string: "0000ABC7-0C0B-0A09-0807-060504030201")
    // 擠乳位置（ 0為左乳 / 1為右乳 ）
    static let BREAST_SIDE       = CBUUID(string: "0000ABC8-0C0B-0A09-0807-060504030201")
    // 最後一個特徵尚未確定作用, 暫識別裝置用
    static let DEVICE_UUID       = CBUUID(string: "0000ABCB-0C0B-0A09-0807-060504030201")
    
    static let ABC1              = CBUUID(string: "0000ABC1-0C0B-0A09-0807-060504030201")
    static let ABC2              = CBUUID(string: "0000ABC2-0C0B-0A09-0807-060504030201")
    static let ABC9              = CBUUID(string: "0000ABC9-0C0B-0A09-0807-060504030201")
    static let FFF0              = CBUUID(string: "0000FFF0-0C0B-0A09-0807-060504030201")
    static let FFE0              = CBUUID(string: "0000FFE0-0C0B-0A09-0807-060504030201")
    static let ABCA              = CBUUID(string: "0000ABCA-0C0B-0A09-0807-060504030201")
    static let FFE1              = CBUUID(string: "0000FFE1-0C0B-0A09-0807-060504030201")
    static let FFE2              = CBUUID(string: "0000FFE2-0C0B-0A09-0807-060504030201")
    static let ABCC              = CBUUID(string: "0000ABCC-0C0B-0A09-0807-060504030201")
    static let ABCD              = CBUUID(string: "0000ABCD-0C0B-0A09-0807-060504030201")
    
    // 沒什麼作用, 僅用於對照原值名稱
    enum CodingKeys: String, CodingKey {
        
        case FIRMWARE_VERSION  = "UUID_FIRMWARE_VERSION"
        
        case BATTERY_SERVICE   = "UUID_BATTERY_LEVEL_SERVICE"
        case BATTERY_LEVEL     = "UUID_BATTERY_LEVEL_CHAR"
        
        case MACHINE_SERVICE   = "UUID_CHAR_SERVICE"
        case MACHINE_STATUS    = "UUID_CHAR_MACHINE_STATUS"
        case LIQUID_HEIGHT     = "UUID_CHAR_TOF"
        case PUMP_STATUS       = "UUID_CHAR_PUMP_STATUS"
        case PUMP_LEVEL        = "UUID_CHAR_PUMP_LEVEL"
        case OPERATION_MODE    = "UUID_CHAR_OPERATE_MODE"
        case BREAST_SIDE       = "UUID_CHAR_MAMMA"
        
        case DEVICE_UUID       = "UUID_CHAR_LAST"
    }
    
}

