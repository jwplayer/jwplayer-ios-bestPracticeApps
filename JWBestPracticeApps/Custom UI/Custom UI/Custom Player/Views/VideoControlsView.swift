//
//  VideoControlsView.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import UIKit
import JWPlayerKit

/// This view is the interface displayed when video content is playing.
class VideoControlsView: XibView {
    /// This view loads `VideoControls.xib`
    override var xibName: String { "VideoControls" }
    
    /// A reference to the progress bar. We need this to update the position of the video in the progress bar
    /// as time is updated.
    @IBOutlet weak var progressView: UIProgressView?
    
    /// A reference to the play/pause toggle button. We need this so we can change the
    /// button's icon when the player state changes.
    @IBOutlet weak var playPauseButton: UIButton?
    
    /// A reference to the "full screen" button. We need this so we can change the
    /// button's icon when the player window state changes.
    @IBOutlet weak var fullScreenButton: UIButton?
    
    override var currentTime: JWTimeData? {
        didSet {
            // Only if a valid position & duration exist are we able to update progress.
            guard let position = currentTime?.position, !position.isNaN,
                    let duration = currentTime?.duration, !duration.isNaN else {
                      progressView?.progress = 0.0
                      return
                  }
            
            // Normalize the progress from 0 to 1, and set it.
            progressView?.progress = Float(position / duration)
        }
    }
    
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
    
    /// We observe the player's window state so we can change the "full screen" button's icon.
    override var windowState: PlayerWindowState {
        didSet {
            switch windowState {
                // When we are a smaller window, we display an arrow icon denoting
                // the option to enter full screen.
            case .normal:
                let image = UIImage(systemName: "arrow.up.left.and.arrow.down.right")
                fullScreenButton?.setImage(image, for: .normal)
                
                // When we are a full screen window, we display an arrow icon denoting
                // the option to dismiss full screen.
            default:
                let image = UIImage(systemName: "arrow.down.right.and.arrow.up.left")
                fullScreenButton?.setImage(image, for: .normal)
            }
        }
    }
    
    override func setupView() {
        super.setupView()
        
        // When the view is created, we reset the progress view to 0.0.
        // For design display purposes, it is at 50% in the xib file, necessitating this.
        progressView?.progress = 0.0
    }
    
    /// This method is called when the play/pause button is tapped.
    @IBAction func onPlayPauseButtonTapped(_ button: UIButton) {
        // Inform the button listener about which button (play or pause) was tapped.
        if playerState == .playing {
            buttonListener?.interfaceButtonTapped(.pause)
        }
        else {
            buttonListener?.interfaceButtonTapped(.play)
        }
    }
    
    /// This method is called when the "full screen" button is tapped.
    @IBAction func onFullScreenTapped(_ button: UIButton) {
        // Inform the button listener about which button ("full screen" or "dismiss full screen") was tapped.
        if windowState == .normal {
            buttonListener?.interfaceButtonTapped(.enterFullScreen)
        }
        else {
            buttonListener?.interfaceButtonTapped(.exitFullScreen)
        }
    }
}
