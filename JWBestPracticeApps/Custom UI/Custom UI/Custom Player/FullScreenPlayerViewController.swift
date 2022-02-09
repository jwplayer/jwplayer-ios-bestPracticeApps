//
//  FullScreenPlayerViewController.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import JWPlayerKit
import UIKit

/// This view controller is used to display the video over the entire screen in landscape orientation.
class FullScreenPlayerViewController: UIViewController {
    /// This hides the home indicator during full screen presentation.
    public override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    /// The interface orientation to use when presenting the view controller.
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get {
            return .landscapeLeft
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
}
