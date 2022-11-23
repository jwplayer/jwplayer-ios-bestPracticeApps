//
//  PlayerViewController.swift
//  Captions
//
//  Created by David Almaguer on 22/11/22.
//

import UIKit
import JWPlayerKit

/**
 Custom protocol to forward caption events.
 */
protocol PlayerCaptionsDelegate: AnyObject {
    func player(_ player: JWPlayer, updatedCaptionList options: [JWMediaSelectionOption])
    func player(_ player: JWPlayer, captionTrackChanged index: Int)
    func player(_ player: JWPlayer, captionPresented caption: [String], at time: JWTimeData)
}

/**
 The `PlayerViewController` handles the caption events from the player and forward them through the `PlayerCaptionsDelegate`.
 */
class PlayerViewController: JWPlayerViewController {
    weak var captionsDelegate: PlayerCaptionsDelegate?
    
    override func jwplayer(_ player: JWPlayer, updatedCaptionList options: [JWMediaSelectionOption]) {
        super.jwplayer(player, updatedCaptionList: options)
        DispatchQueue.main.async { [weak self] in
            self?.captionsDelegate?.player(player, updatedCaptionList: options)
        }
    }
    
    override func jwplayer(_ player: JWPlayer, captionTrackChanged index: Int) {
        super.jwplayer(player, captionTrackChanged: index)
        DispatchQueue.main.async { [weak self] in
            self?.captionsDelegate?.player(player, captionTrackChanged: index)
        }
    }
    
    override func jwplayer(_ player: JWPlayer, captionPresented caption: [String], at time: JWTimeData) {
        super.jwplayer(player, captionPresented: caption, at: time)
        DispatchQueue.main.async { [weak self] in
            self?.captionsDelegate?.player(player, captionPresented: caption, at: time)
        }
    }
}
