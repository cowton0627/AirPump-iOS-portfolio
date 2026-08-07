//
//  VideoViewController.swift
//  Breast Pump
//
//  Created by user on 2022/3/21.
//

import UIKit

/// 影音區頁面
class VideoViewController: UIViewController {
    // MARK: - Properties
    // navigationBar用圖顯示原樣
    private let menuIcon = UIImage(systemName: "line.3.horizontal")
    
    private let rowHeight = 43.5
//    private let leftBarImage = UIImage(systemName: "plus")
//    private let rightBarImage = UIImage(systemName: "circle")
    
    // MARK: - IBOutlet
    @IBOutlet weak var mediaTypeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    
    // MARK: - Methods
    private func configureUI() {
        // 設定navigationBar顯圖, 與buttonAction
        let leftBarItem = UIBarButtonItem(image: menuIcon,
                                          style: .plain,
                                          target: .none,
                                          action: nil)
        leftBarItem.accessibilityLabel = "偏好設定"
        navigationItem.setLeftBarButton(leftBarItem, animated: true)

        for button in allButtons(in: view) {
            let actions = button.actions(forTarget: self, forControlEvent: .touchUpInside) ?? []
            if actions.contains("downloadButtonTapped:") {
                button.accessibilityLabel = "下載影音"
                ensureAccessibleTouchTarget(for: button)
            } else if actions.contains("popoverButtonTapped:") {
                button.accessibilityLabel = "選擇影音類型"
                ensureAccessibleTouchTarget(for: button)
            } else if button.currentTitle?.trimmingCharacters(in: .whitespaces).isEmpty == true {
                button.isAccessibilityElement = false
            }
        }
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarImage, style: .plain, target: self, action: nil)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightBarImage, style: .plain, target: self, action: nil)
        
    }

    private func allButtons(in root: UIView) -> [UIButton] {
        root.subviews.flatMap { view in
            ((view as? UIButton).map { [$0] } ?? []) + allButtons(in: view)
        }
    }

    private func ensureAccessibleTouchTarget(for button: UIButton) {
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
    }
    
    // MARK: - IBAction
    @IBAction func popoverButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: .Video, bundle: nil)
        let vc = storyboard.instantiateVC(withClass: MediaTypePopoverTableViewController.self)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = sender.self
        vc.popoverPresentationController?.sourceRect =
        CGRect(origin: .init(
            x: sender.bounds.minX + sender.frame.size.width/2,
            y: sender.bounds.maxY + rowHeight),
               size: sender.frame.size)
        vc.preferredContentSize = CGSize(width: 130, height: rowHeight * 3)
        vc.popoverPresentationController?.delegate = self
        vc.delegate = self
        present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        print("downloading...")
    }
    
}

extension VideoViewController: UIPopoverPresentationControllerDelegate {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        segue.destination.preferredContentSize = CGSize(width: 150, height: 200)
//        segue.destination.popoverPresentationController?.delegate = self
//    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

// MARK: - PopoverDelegate
extension VideoViewController: MediaTypePopoverTableViewControllerDelegate {
    func changeMediaTypeLabel(text: String) {
        mediaTypeLabel.text = text
    }

}

extension VideoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(VideoCollectionViewCell.self)", for: indexPath) as? VideoCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.mediaImageView.image = UIImage(systemName: "plus")
        cell.backgroundColor = .orange
        return cell
    }
    
    
}
