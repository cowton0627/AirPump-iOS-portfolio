//
//  UIStoryboard+Ext.swift
//  Breast Pump
//
//  Created by user on 2022/3/28.
//

import Foundation
import UIKit

extension UIStoryboard {
    // 將所有storyboard名集中於此
    enum BoardName: String {
        case LaunchScreen
        case Main
        case Preference
        case Operation
        case Records
        case Discussion
        case Video
        case LowBatteryStoryboard
    }
    
    // 定義
    convenience init(name: BoardName, bundle: Bundle? = nil) {
        self.init(name: name.rawValue, bundle: bundle)
    }
    // 使用
//    let storyboard = UIStoryboard(name: .Preference)
    
    // 定義
    static func makeBoard(name: BoardName, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: name.rawValue, bundle: bundle)
    }
    // 使用
//    let storyboard = UIStoryboard.makeBoard(name: .Preference)
    
}

extension UIStoryboard {
    
    func instantiateVC<T: UIViewController>(withClass name: T.Type) -> T {
        guard let vc = self.instantiateViewController(withIdentifier: String(describing: name)) as? T else {
            fatalError("Couldn’t instantiate view controller with identifier \(String(describing: name))")
        }
        return vc
    }
    
}
