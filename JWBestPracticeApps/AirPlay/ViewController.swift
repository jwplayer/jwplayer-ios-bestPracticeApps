//
//  ViewController.swift
//  AirPlay
//
//  Created by David Almaguer on 10/9/19.
//  Copyright © 2019 Karim Mourra. All rights reserved.
//

import UIKit
import AVKit // AVKit allow us to use AVRoutePickerView
import MediaPlayer // MediaPlayer allow us to use MPVolumeView

class ViewController: BasicVideoViewController {
    
    // Make sure to look at the 'setUpBackgroundAudio' function in the AppDelegate.
    // It's necessary to make sure the AirPlay runs smoothly.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        player?.config.autostart = false
        
        setupAirPlayButton()
    }
    
    func setupAirPlayButton() {
        var buttonView: UIView? = nil
        let buttonFrame = CGRect(x: 0, y: 0, width: 44, height: 44)
        
        // It's highly recommended use the AVRoutePickerView in order to avoid AirPlay issues after iOS 11.
        if #available(iOS 11.0, *) {
            let airplayButton = AVRoutePickerView(frame: buttonFrame)
            airplayButton.activeTintColor = UIColor.blue
            airplayButton.tintColor = UIColor.gray
            buttonView = airplayButton
        } else {
            // If you still supporting previous iOS versions you can use MPVolumeView
            let airplayButton = MPVolumeView(frame: buttonFrame)
            airplayButton.showsVolumeSlider = false
            buttonView = airplayButton
        }
        
        // If there is not AirPlay devices available, the button will not being displayed.
        let buttonItem = UIBarButtonItem(customView: buttonView!)
        self.navigationItem.setRightBarButton(buttonItem, animated: true)
    }
}

