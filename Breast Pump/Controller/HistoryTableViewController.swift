//
//  RecordsTableViewController.swift
//  Breast Pump
//
//  Created by Chunli Cheng on 2021/12/13.
//

import UIKit

/// 歷史紀錄
class HistoryTableViewController: UITableViewController {

    var expendedDataList: [Bool] = [false, false, false]
    let sectionDataList: [String] = ["2022.01.20", "2022.02.20", "2022.03.20"]
    let cellDataList: [[String]] = [
        ["上午 9:00", "下午 13:00", "下午 16:00"],
        ["上午 6:00", "上午 9:00", "下午 13:00", "下午 16:00", "下午 18:00"],
        ["上午 4:00", "上午 6:00", "上午 9:00", "下午 13:00", "下午 16:00", "下午 18:00", "下午 20:00"]
    ]
    
    private let themeColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        let sectionViewNib: UINib = UINib(nibName: "\(HistorySectionView.self)",
//                                          bundle: nil)
//        self.tableView.register(sectionViewNib, forHeaderFooterViewReuseIdentifier: "\(HistorySectionView.self)")
        self.tableView.register(viewWithClass: HistorySectionView.self)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.expendedDataList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 展開與否判斷 row有多少
        if self.expendedDataList[section] {
            return self.cellDataList[section].count
        } else {
            return 0
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(HistoryTableViewCell.self)", for: indexPath) as? HistoryTableViewCell else {
//            return UITableViewCell()
//        }
        let cell = tableView.dequeueReusableCell(withClass: HistoryTableViewCell.self, for: indexPath)
        cell.endTimeLabel.text = self.cellDataList[indexPath.section][indexPath.row]
//        cell.endTimeLabel.text = "下午 1:30"
//        cell.totalAmountLabel.text = "140 mL"
//        cell.leftAmountLabel.text = "左: 60 mL"
//        cell.leftDurationLabel.text = "30 分鐘"
//        cell.rightAmountLabel.text = "右: 80 mL"
//        cell.rightDurationLabel.text = "35 分鐘"

        return cell
    }
    
    
    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(HistorySectionView.self)") as? HistorySectionView else {
//            return UIView()
//        }
        let headerView = tableView.dequeueReusableHeaderFooterView(withClass: HistorySectionView.self)
        
        headerView.isExpanded = self.expendedDataList[section]
        headerView.buttonTag = section
        headerView.delegate = self
        
        // 圖示 "△" : "▽"
        headerView.expandButton.setTitle(
            self.expendedDataList[section] == true ? "▲" : "▼" , for: .normal)
        headerView.expandButton.setTitleColor(.black, for: .normal)
        headerView.expandButton.setTitleColor(themeColor, for: .normal)
        // 日期
        headerView.dateLabel.text = self.sectionDataList[section]
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if isExpendDataList[indexPath.section] {
//            tableView.reloadSections([indexPath.section], with: .automatic)
//        }
//        isExpendDataList[indexPath.section] = !isExpendDataList[indexPath.section]

       
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension HistoryTableViewController: HistorySectionViewDelegate {
    func sectionView(_ sectionView: HistorySectionView,
                     tappedTag: Int, isExpanded: Bool) {
//        tableView.beginUpdates()
        self.expendedDataList[tappedTag] = !isExpanded
        self.tableView.reloadSections(IndexSet(integer: tappedTag), with: .automatic)
//        tableView.endUpdates()
    }
    
}
