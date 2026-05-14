//
//  Validate.swift
//  Breast Pump
//
//  Created by user on 2022/3/22.
//

import Foundation

import Foundation

// 常用正則表示式
enum Validate {
    case userName(_: String)    // 登入名稱
    case nickName(_: String)    // 暱稱
    case password(_: String)    // 密碼
    case email(_: String)       // 信箱
    case phoneNum(_: String)    // 手機
    case carNum(_: String)      // 車牌
    case URL(_: String)         // 網址
    case IP(_: String)          // IP位址
    case idCard(_: String)      // 身份證字號
    case chinese(_: String)     // 中文
    case numbers(_: String)     // 只包含數字
    case lettersAndNumbers(_: String) // 只包含字母和數字
    
    var isRight: Bool {
        var predicateStr:String!
        var currObject:String!
        switch self {
        case let .userName(str):
            predicateStr = "^[A-Za-z0-9]{6,20}+$"
            currObject = str
        case let .nickName(str):
            predicateStr = "^[\\u4e00-\\u9fa5]{4,8}$"
            currObject = str
        case let .password(str):
            predicateStr = "^[a-zA-Z0-9]{6,12}+$"
            currObject = str
        case let .email(str):
            predicateStr = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
            currObject = str
        case let .phoneNum(str):
            predicateStr = "^1(3[4-9]|4[7]|5[0-27-9]|7[08]|8[2-478])\\d{8}$"
            currObject = str
        case let .carNum(str):
            predicateStr = "^[A-Za-z]{1}[A-Za-z_0-9]{5}$"
            currObject = str
       
        case let .URL(str):
            predicateStr = "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
            currObject = str
        case let .IP(str):
            predicateStr = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
            currObject = str
        case let .idCard(str):
            predicateStr = "(^[1-9]\\d{5}(18|19|([23]\\d))\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$)|(^[1-9]\\d{5}\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{2}$)"
            currObject = str
        case let .chinese(str):
            predicateStr = "^[\\u4e00-\\u9fa5]{0,100}$"
            currObject = str
        case let .numbers(str):
            predicateStr = "^[0-9]+$"
            currObject = str
        case let .lettersAndNumbers(str):
            predicateStr = "^[a-zA-Z0-9]{1,30}+$"
            currObject = str
        
        }
        
        let predicate =  NSPredicate(format: "SELF MATCHES %@" ,predicateStr)
        return predicate.evaluate(with: currObject)
    }
    
}
