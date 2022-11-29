//
//  ViewController.swift
//  Captions
//
//  Created by David Almaguer on 22/11/22.
//

import UIKit
import JWPlayerKit

// This best practices app demonstrates the following functionality:
// 1. Listen for caption events
// 2. Disable caption rendering
// 3. Display captions in a different view.

class ViewController: UIViewController, PlayerCaptionsDelegate {
    
    @IBOutlet weak var captionRenderingSwitch: UISwitch!
    @IBOutlet weak var captionTrackLabel: UILabel!
    @IBOutlet weak var captionsTextView: UITextView!
    
    /// In order to delegate caption events, the `PlayerViewController` subclasses the `JWPlayerViewController` and forwards caption events through the `PlayerCaptionsDelegate`.
    var playerVC: PlayerViewController?
    
    var player: JWPlayerProtocol? {
        return playerVC?.player
    }
    
    // MARK: - View life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: 1. Listen for caption events
        
        /// Assing this view controller to the `captionsDelegate` so it can be informed about captions events.
        playerVC?.captionsDelegate = self
        
        /// Open a `do-catch` block to handle possible errors with the builders.
        do {
            /// First, use the `JWPlayerItemBuilder` to create a `JWPlayerItem` that will be used by the player configuration.
            let playerItem = try JWPlayerItemBuilder()
                .file(URL(string: "https://wowzaec2demo.streamlock.net/vod-multitrack/_definst_/smil:ElephantsDream/elephantsdream2.smil/playlist.m3u8")!)
                .build()
            
            /// Second, create a player config with the created `JWPlayerItem`.
            let configuration = try JWPlayerConfigurationBuilder()
                .playlist(items: [playerItem])
                .build()
            
            /// Third, use the created `JWPlayerConfiguration` to set up the player.
            player?.configurePlayer(with: configuration)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /**
         Since we are using a view container to embed the custom subclass of the `JWPlayerViewController`, it's necessary to store the reference for its future usage.
         */
        guard let playerVC = segue.destination as? PlayerViewController else {
            return
        }
        self.playerVC = playerVC
    }

    // MARK: - IBActions
    
    @IBAction func captionRenderingChanged(_ sender: UISwitch) {
        // MARK: 2. Disable caption rendering
        /**
         If `true`, the player will not render captions on the screen if a caption track is selected, however, you will still receive caption events, including `func jwplayer(_ player: JWPlayer, captionPresented caption: [String], at time: JWTimeData)`. By default, this flag is `false`.
         */
        player?.suppressesCaptionRendering = sender.isOn
    }
    
    // MARK: - JWAVDelegate
    
    /**
     This event reports the available caption list for the current player item.
     */
    func player(_ player: JWPlayer, updatedCaptionList options: [JWMediaSelectionOption]) {
        let enableCaptionRenderingSwitch = options.count > 1
        DispatchQueue.main.async { [weak self] in
            self?.captionRenderingSwitch.isEnabled = enableCaptionRenderingSwitch
        }
    }
    
    /**
     This event is fired when a new subtitle track has been chosen, either through UI or API.
     */
    func player(_ player: JWPlayer, captionTrackChanged index: Int) {
        let currentTrack = player.captionsTracks[index]
        DispatchQueue.main.async { [weak self] in
            self?.captionsTextView.text = nil
            self?.captionTrackLabel.text = currentTrack.name
        }
    }
    
    /**
     This event is fired when the player hits a set of caption strings, regardless the `JWPlayer.suppressessCaptionRendering` is enabled.
     */
    func player(_ player: JWPlayer, captionPresented caption: [String], at time: JWTimeData) {
        // MARK: 3. Display captions in a different view.
        DispatchQueue.main.async { [weak self] in
            self?.captionsTextView.text = caption.joined(separator: "\n")
        }
    }
}
