//
//  VideoControlsView.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import UIKit
import JWPlayerKit

class VideoControlsView: XibView {
    override var xibName: String { "VideoControls" }
    
    @IBOutlet weak var progressView: UIProgressView?
    @IBOutlet weak var playPauseButton: UIButton?
    @IBOutlet weak var fullScreenButton: UIButton?
    
    override var currentTime: JWTimeData? {
        didSet {
            guard let position = currentTime?.position,
                  let duration = currentTime?.duration else {
                      progressView?.progress = 0.0
                      return
                  }
            
            progressView?.progress = Float(position / duration)
        }
    }
    
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
    
    override func onWindowStateChanged() {
        super.onWindowStateChanged()
        
        switch windowState {
        case .normal:
            let image = UIImage(systemName: "arrow.up.left.and.arrow.down.right")
            fullScreenButton?.setImage(image, for: .normal)
        default:
            let image = UIImage(systemName: "arrow.down.right.and.arrow.up.left")
            fullScreenButton?.setImage(image, for: .normal)
        }
    }
    
    override func setupView() {
        super.setupView()
        
        progressView?.progress = 0.0
    }
    
    @IBAction func onPlayPauseButtonTapped(_ button: UIButton) {
        if playerState == .playing {
            buttonListener?.interfaceButtonTapped(.pause)
        }
        else {
            buttonListener?.interfaceButtonTapped(.play)
        }
    }
    
    @IBAction func onFullScreenTapped(_ button: UIButton) {
        if windowState == .normal {
            buttonListener?.interfaceButtonTapped(.maximizeWindow)
        }
        else {
            buttonListener?.interfaceButtonTapped(.minimizeWindow)
        }
    }
}
