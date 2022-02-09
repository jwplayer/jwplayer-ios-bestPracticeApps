//
//  AdControlsView.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import UIKit
import JWPlayerKit

/// This view is the interface displayed when an advertisement is playing.
class AdControlsView: XibView {
    /// This view loads `AdControls.xib`
    override var xibName: String { "AdControls" }
    
    /// A reference to the play/pause toggle button. We need this so we can change the
    /// button's icon when the player state changes.
    @IBOutlet weak var playPauseButton: UIButton?
    
    /// We observe the player's state so we can change the play/pause button's icon.
    override var playerState: JWPlayerState {
        didSet {
            switch playerState {
                // If we are currently playing, we display the pause icon.
            case .playing:
                let image = UIImage(systemName: "pause.fill")
                playPauseButton?.setImage(image, for: .normal)
                // For all other states we display the play icon.
            default:
                let image = UIImage(systemName: "play.fill")
                playPauseButton?.setImage(image, for: .normal)
            }
        }
    }
    
    /// This method is called when the play/pause button is tapped.
    @IBAction func onPlayPauseButtonTapped(_ button: UIButton) {
        if playerState == .playing {
            buttonListener?.interfaceButtonTapped(.pause)
        }
        else {
            buttonListener?.interfaceButtonTapped(.play)
        }
    }
    
    /// This method is called when the "Skip Ad" button is tapped.
    @IBAction func onSkipTapped(_ button: UIButton) {
        buttonListener?.interfaceButtonTapped(.skipAd)
    }
    
    /// This method is called whe the "Learn More" button is tapped.
    @IBAction func onLearnMoreTapped(_ button: UIButton) {
        buttonListener?.interfaceButtonTapped(.learnMore)
    }
}
