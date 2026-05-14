//
//  Data+Ext.swift
//  Breast Pump
//
//  Created by Chunli Cheng on 2022/2/10.
//

import Foundation

// 處理16進位數值: %02x是以零補齊兩位數, 超過則顯示全部; %hhx是只輸出最低兩位數（讀值用）
extension Data {
    func hexToStr() -> String {
        return map { String(format: "%02hhx", $0) }.joined() // joined為去掉空格
    }
}

// Converting Hex String to NSData（寫入用）
extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i * 2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}

extension Data {
    // 印出有縮排的解碼字
    func prettyPrintedJSONString() {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyJSONString = String(data: jsonData, encoding: .utf8) else {
                  print("Failed to read JSON Object.")
                  return
        }
        print(prettyJSONString)
    }
    
}
