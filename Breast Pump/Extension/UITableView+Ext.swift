//
//  UITableView+Ext.swift
//  Breast Pump
//
//  Created by user on 2022/3/22.
//

import Foundation
import UIKit

extension UITableView {
    // register UITableViewCell
    func register(cellWithClass name: AnyClass) {
        /*
            TableViewCell較為特殊,
            一般在storyboard設定class無法用xib的方式註冊, 因為並無xib的檔案,
            故必須在storyboard中設定reuseIdentifier,
            若全由程式碼建立則可用註解掉的第三行
         */
//        let nibName = UINib(nibName: String(describing: name), bundle: nil)
//        register(nibName, forCellReuseIdentifier: String(describing: name))
//        register(name, forCellReuseIdentifier: String(describing: name))
    }
    
    // register UITableViewHeaderFooterView
    func register(viewWithClass name: AnyClass) {
        let nibName = UINib(nibName: String(describing: name), bundle: nil)
        register(nibName, forHeaderFooterViewReuseIdentifier: String(describing: name))
//        register(name, forHeaderFooterViewReuseIdentifier: String(describing: name))
    }
}

extension UITableView {
    // dequeue reusable UITableViewCell using class name
    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: name)) as? T else {
            fatalError("Couldn't find UITableViewCell for \(String(describing: name))")
        }
        return cell
    }
    
    // dequeue reusable UITableViewCell using class name for indexPath
    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError("Couldn't find UITableViewCell for \(String(describing: name))")
        }
        return cell
    }
    
    // dequeue reusable UITableViewHeaderFooterView using class name
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withClass name: T.Type) -> T {
        guard let sectionView = dequeueReusableHeaderFooterView(withIdentifier: String(describing: name)) as? T else {
            fatalError("Couldn't find UITableViewHeaderFooterView for \(String(describing: name))")
        }
        return sectionView
    }
    
}
