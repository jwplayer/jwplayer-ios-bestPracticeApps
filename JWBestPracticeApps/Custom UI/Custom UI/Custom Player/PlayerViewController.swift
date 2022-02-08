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
            // Load the config, and if necessary, trigger viewDidLoad.
            // If viewDidLoad is not triggered, then playerView is nil.
            guard let config = self.config, view != nil else {
                return
            }
            
            playerView.player.configurePlayer(with: config)
        }
    }
    
    // MARK: - Player View Handling
    
    private var playerView: JWPlayerView!
    private var player: JWPlayer {
        return playerView.player
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        // Setup the player view.
        let playerView = JWPlayerView()
        view.addSubview(playerView)
        playerView.fillSuperview()
        self.playerView = playerView
        
        // Add the controls.
        let adControls = AdControlsView(frame: view.bounds)
        view.addSubview(adControls)
        adControls.fillSuperview()
        
        // Setup the player
        playerView.player.delegate = self
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
