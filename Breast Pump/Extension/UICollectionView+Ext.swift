//
//  UICollectionView+Ext.swift
//  Breast Pump
//
//  Created by user on 2022/3/22.
//

import Foundation
import UIKit

extension UICollectionView {
    // dequeue reusable UICollectionViewCell using class name for indexPath
    func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: name), for: indexPath) as? T else {
           fatalError("Counldn't find UICollectionViewCell for \(String(describing: name))")
        }
        return cell
    }
    
}
