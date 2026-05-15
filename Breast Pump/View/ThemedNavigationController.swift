//
//  ThemedNavigationController.swift
//  Breast Pump
//
//  Created by Chunli Cheng on 2021/12/14.
//

import UIKit

/// 客製化導航視圖控制器
class ThemedNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 讓 barButtonItem 上的 SF Symbol / template image 染成白色
        UINavigationBar.appearance().tintColor = .white
        /*
            iOS13以後的版本(如: iOS14、iOS15)採用barAppearence來調整navigationBar時,
            需注意:
            iOS15調整的是scrollEdgeAppearance,
            iOS14調整的是standardAppearence,
            且standard預設效果為毛玻璃, scrollEdge預設效果為透明(nil)ㄌ
         
            簡單的作法為：NavBar與TabBar皆設定scrollEdge、standard，便可滿足iOS14、15。
        */

        if #available(iOS 15.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)
            barAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 28)]
            // 捲動內容有重疊時
            UINavigationBar.appearance().standardAppearance = barAppearance
            // 捲動內容沒有重疊時; 設定以取消半透明
            UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
            
        } else if #available(iOS 14.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)
            barAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 28)]
            // 正常高度的NavBar; 設定以取消半透明
            UINavigationBar.appearance().standardAppearance = barAppearance
            // 放大高度的NavBar
            UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
            
        } else {
            // 取消navigationBar的半透明
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 28)]
        }

    }
    

}
