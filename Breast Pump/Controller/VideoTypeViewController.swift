//
//  VideoTypeViewController.swift
//  Breast Pump
//
//  Created by user on 2022/7/13.
//

import UIKit

class VideoTypeViewController: UIViewController {
    
    // MARK: - Properties
    var isPlaying: Bool = true {
        didSet {
            palyPauseButton.isSelected = isPlaying
        }
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var reverseBackground: UIView!
    @IBOutlet weak var playPauseBackground: UIView!
    @IBOutlet weak var forwardBackground: UIView!
    
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var palyPauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - IBOutlet
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        
    }
    
    
    // MARK: - Methods
    private func configureUI() {
//        reverseBackground.layer.cornerRadius = reverseBackground.frame.height/2
//        reverseBackground.clipsToBounds = true
//        playPauseBackground.layer.cornerRadius = playPauseBackground.frame.height/2
//        playPauseBackground.clipsToBounds = true
//        forwardBackground.layer.cornerRadius =
//        forwardBackground.frame.height/2
//        forwardBackground.clipsToBounds = true
        [reverseBackground, playPauseBackground, forwardBackground].forEach { view in
            view?.layer.cornerRadius = view!.frame.height/2
            view?.clipsToBounds = true
            view?.alpha = 0.0
        }
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
