//
//  MediaTypePopoverTableViewController.swift
//  Breast Pump
//
//  Created by user on 2022/7/1.
//

import UIKit

protocol MediaTypePopoverTableViewControllerDelegate: AnyObject {
    func changeMediaTypeLabel(text: String)
}

/// 影音類型切換Popover
class MediaTypePopoverTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let allMediaIndexPath = IndexPath(row: 0, section: 0)
    private let photoIndexPath    = IndexPath(row: 1, section: 0)
    private let videoIndexPath    = IndexPath(row: 2, section: 0)
    
    weak var delegate: MediaTypePopoverTableViewControllerDelegate?
    
    // MARK: - IBOutlet
    @IBOutlet var checkMarkButtons: [UIButton]!
    

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        configureUI()
    }
    
    private func configureUI() {
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        checkMarkButtons[0].isHidden = false
        checkMarkButtons[1].isHidden = true
        checkMarkButtons[2].isHidden = true
    }
    
    private func checkMarkButtonsToggle() {
        for checkMarkButton in checkMarkButtons {
            checkMarkButton.isHidden.toggle()
        }
    }

    // MARK: - Table view data source


    
    // MARK: - Table view delegate
//    override func tableView(_ tableView: UITableView,
//                            viewForFooterInSection section: Int) -> UIView? {
//        return UIView()
//    }
    
    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var mediaTypeString: String?
        switch indexPath {
        case allMediaIndexPath:
            mediaTypeString = "所有項目"
            checkMarkButtons[0].isHidden.toggle()
            checkMarkButtons[1].isHidden = true
            checkMarkButtons[2].isHidden = true
        case photoIndexPath:
            mediaTypeString = "相簿"
            checkMarkButtons[1].isHidden.toggle()
            checkMarkButtons[0].isHidden = true
            checkMarkButtons[2].isHidden = true
        case videoIndexPath:
            mediaTypeString = "影片"
            checkMarkButtons[2].isHidden.toggle()
            checkMarkButtons[0].isHidden = true
            checkMarkButtons[1].isHidden = true
        default: break
        }
        delegate?.changeMediaTypeLabel(text: mediaTypeString!)
    }


}
