//
//  VideoControlsView.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import UIKit

class VideoControlsView: XibView {
    override var xibName: String { "VideoControls" }
    
    @IBOutlet weak var progressView: UIProgressView?
    
    override func setupView() {
        super.setupView()
        
        progressView?.progress = 0.0
    }
    
    @IBAction func onPlayPauseButtonTapped(_ button: UIButton) {
        if state == .playing {
            buttonListener?.interfaceButtonTapped(.pause)
        }
        else {
            buttonListener?.interfaceButtonTapped(.play)
        }
    }
    
    @IBAction func onFullScreenTapped(_ button: UIButton) {
        print("tapped")
    }
}
