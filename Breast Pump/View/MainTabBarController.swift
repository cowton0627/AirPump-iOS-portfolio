//
//  MainTabBarController.swift
//  Breast Pump
//
//  Created by Chunli Cheng on 2022/2/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
            iOS13以後的版本(如: iOS14、iOS15)採用barAppearence來調整tabBar時,
            需注意:
            iOS15調整的是standardAppearence 及 scrollEdgeAppearance
            iOS14調整的是standardAppearence,
            且standard預設效果為毛玻璃, scrollEdge預設效果為透明(nil)
         
            簡單的作法為：NavBar與TabBar皆設定scrollEdge、standard，便可滿足iOS14、15。
        */

//        #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.6500527518)
       
        if #available(iOS 15.0, *) {
            let barAppearance = UITabBarAppearance()
            barAppearance.backgroundColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)
            barAppearance.stackedLayoutAppearance.selected.iconColor = .white
            barAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
            barAppearance.stackedLayoutAppearance.normal.iconColor = .systemGray4
            barAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray4]
            // 捲動內容有重疊時
            UITabBar.appearance().standardAppearance = barAppearance
            // 捲動內容沒有重疊時; 設定以取消半透明
            UITabBar.appearance().scrollEdgeAppearance = barAppearance
//            UITabBar.appearance().tintColor = .white
            
        } else if #available(iOS 14.0, *) {
            let barAppearance = UITabBarAppearance()
            barAppearance.backgroundColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)
            barAppearance.stackedLayoutAppearance.selected.iconColor = .white
            barAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
            barAppearance.stackedLayoutAppearance.normal.iconColor = .systemGray4
            barAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray4]
            // 設定以取消半透明
            UITabBar.appearance().standardAppearance = barAppearance
//            UITabBar.appearance().tintColor = .white

        } else {
            // 取消tabBar的半透明
            tabBar.isTranslucent = false
            tabBar.barTintColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)
            // 選取時顏色
            tabBar.tintColor = .white
            // 未選時顏色
            tabBar.unselectedItemTintColor = .systemGray

        }
        
        self.viewControllers?[0].tabBarItem.image = UIImage(systemName: "person.fill")
        self.viewControllers?[1].tabBarItem.image = UIImage(systemName: "rectangle.3.offgrid.fill")
        self.viewControllers?[2].tabBarItem.image = UIImage(systemName: "text.bubble.fill")
        self.viewControllers?[3].tabBarItem.image = UIImage(systemName: "video.fill")
        self.viewControllers?[4].tabBarItem.image = UIImage(systemName: "bell.fill")
        
        
        
    }

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
