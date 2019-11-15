//
//  AppDelegate.swift
//  AirPlay
//
//  Created by David Almaguer on 10/9/19.
//  Copyright © 2019 Karim Mourra. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setUpBackgroundAudio()
        
        return true
    }
    
    // Set up the app for playback. Necessary for AirPlay to run smoothly.
    func setUpBackgroundAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        do {
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("There was an error setting the audio session to active.")
        }
    }
}

