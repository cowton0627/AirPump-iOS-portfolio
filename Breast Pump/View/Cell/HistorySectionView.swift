//
//  HistorySectionView.swift
//  Breast Pump
//
//  Created by user on 2022/3/22.
//

import UIKit

protocol HistorySectionViewDelegate: AnyObject {
    func sectionView(_ sectionView: HistorySectionView,
                     tappedTag: Int, isExpanded: Bool)
}

class HistorySectionView: UITableViewHeaderFooterView {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!

    weak var delegate: HistorySectionViewDelegate?
    var buttonTag: Int!
    var isExpanded: Bool!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func expandButtonTapped(_ sender: UIButton) {
        self.delegate?.sectionView(self,
                              tappedTag: buttonTag,
                              isExpanded: isExpanded)
        
        
    }
    
    
}
