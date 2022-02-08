//
//  PlayerViewController.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import JWPlayerKit

/**
 The PlayerViewController contains the JWPlayerView, and handles the events and changing of the interfaces.
 */
class PlayerViewController: ViewController, JWPlayerDelegate {
    
    // MARK: - Public Methods and Properties
    
    var config: JWPlayerConfiguration? {
        didSet {
            guard let config = self.config else {
                return
            }
            playerView.player.configurePlayer(with: config)
        }
    }
    
    // MARK: - Player View Handling
    
    private var playerView: JWPlayerView {
        return view as! JWPlayerView
    }
    
    override func loadView() {
        view = JWPlayerView()
        view.backgroundColor = .black
        
        let adControls = AdControlsView(frame: view.bounds)
        view.addSubview(adControls)
        adControls.fillSuperview()
    }
    
    // MARK: - JWPlayerDelegate
    
    func jwplayerIsReady(_ player: JWPlayer) {
        player.play()
    }
    
    func jwplayer(_ player: JWPlayer, failedWithError code: UInt, message: String) {
        print("JWPlayer Error (\(code)): \(message)")
    }
    
    func jwplayer(_ player: JWPlayer, failedWithSetupError code: UInt, message: String) {
        print("JWPlayer Setup Error (\(code)): \(message)")
    }
    
    func jwplayer(_ player: JWPlayer, encounteredWarning code: UInt, message: String) {
        print("JWPlayer Warning (\(code)): \(message)")
    }
    
    func jwplayer(_ player: JWPlayer, encounteredAdWarning code: UInt, message: String) {
        print("JWPlayer Ad Warning (\(code)): \(message)")
    }
    
    func jwplayer(_ player: JWPlayer, encounteredAdError code: UInt, message: String) {
        print("JWPlayer Ad Error (\(code)): \(message)")
    }
}
