//
//  AdControlsView.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import UIKit

class AdControlsView: XibView {
    override var xibName: String { "AdControls" }
    
    @IBOutlet weak var playPauseButton: UIButton?
    
    override func onPlayerStateChanged() {
        super.onPlayerStateChanged()
        
        switch playerState {
        case .playing:
            let image = UIImage(systemName: "pause.fill")
            playPauseButton?.setImage(image, for: .normal)
        default:
            let image = UIImage(systemName: "play.fill")
            playPauseButton?.setImage(image, for: .normal)
        }
    }
    
    @IBAction func onPlayPauseButtonTapped(_ button: UIButton) {
        if playerState == .playing {
            buttonListener?.interfaceButtonTapped(.pause)
        }
        else {
            buttonListener?.interfaceButtonTapped(.play)
        }
    }
    
    @IBAction func onSkipTapped(_ button: UIButton) {
        buttonListener?.interfaceButtonTapped(.skipAd)
    }
    
    @IBAction func onLearnMoreTapped(_ button: UIButton) {
        buttonListener?.interfaceButtonTapped(.learnMore)
    }
}
