//
//  DefaultStringInterpolation+Ext.swift
//  Breast Pump
//
//  Created by Chunli Cheng on 2022/2/24.
//

import Foundation

// 處理字串插值需不斷加 String(describing: optional)來消除警示的問題
extension DefaultStringInterpolation {
    mutating func appendInterpolation<T>(_ optional: T?) {
        appendLiteral(String(describing: optional))
    }
}
