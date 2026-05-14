//
//  RLM_BreastPump.swift
//  Breast Pump
//
//  Created by user on 2022/3/18.
//

import Foundation
import RealmSwift

@objcMembers
class RLM_BreastPump: Object {
    
    dynamic var uuid: String = UUID().uuidString
    /// 主鍵
    dynamic var primaryKey: String = ""
    override static func primaryKey() -> String? { return "primaryKey" }

    /// 該筆紀錄的使用者ID
    dynamic var userId: Int = -1
    /// 資料是否已上傳雲端
    dynamic var isInCloud: Bool = false
    
    /// 吸乳器位置
    dynamic var breastSide: String = ""
//    dynamic var breastSide: Int = 10
    
    /// 記錄日期
    dynamic var date: Date = Date()
    /// 開始時間
    dynamic var startTime: String = ""
    /// 結束時間
    dynamic var endTime: String = ""
    /// 持續時間
    dynamic var duration: String = ""

    /// 單次集乳量
    dynamic var amount: Int = 0 // 由Data取出first, 再轉成Int
    /// 結束時強度
    dynamic var strength: String = ""
    /// 結束時模式
    dynamic var mode: String = ""

    
}

extension RLM_BreastPump {
    
    private func updatePrimaryKey() {
        // 每150秒，相同UUID、user不重複記錄
        primaryKey = "\(uuid)" + "\(userId)" + Int((date.timeIntervalSince1970)/60*60).description
    }
    
}
