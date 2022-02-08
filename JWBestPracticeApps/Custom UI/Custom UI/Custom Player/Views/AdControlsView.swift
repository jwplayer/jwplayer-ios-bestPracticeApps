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
    
    @IBAction func onPlayPauseButtonTapped(_ button: UIButton) {
        print("tapped")
    }
    
    @IBAction func onSkipTapped(_ button: UIButton) {
        print("tapped")
    }
    
    @IBAction func onLearnMoreTapped(_ button: UIButton) {
        print("tapped")
    }
}
