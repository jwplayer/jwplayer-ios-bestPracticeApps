//
//  PlayerViewController.swift
//  Google IMA Companion Ads
//
//  Created by David Almaguer on 01/02/23.
//

import Foundation
import UIKit
import JWPlayerKit

class PlayerViewController: JWPlayerViewController {
    
    //pragma MARK: - Related advertising methods

    // Reports when an ad event is emitted by the player.
    override func jwplayer(_ player: JWPlayer, adEvent event: JWAdEvent) {
        super.jwplayer(player, adEvent: event)

        switch event.type {
        case .companion:
            guard let companions = event[.companions] as? [JWAdCompanion],
                  let tag = event[.tag] as? URL else {
                return
            }
            
            print("VAST Ad Tag: \(tag.absoluteString)\n")
            
            companions.forEach { companion in
                print("Companion Ad Size: \(companion.size.width)x\(companion.size.height)")
                print("Companion Ad ClickThroughUrl: \(companion.clickUrl?.absoluteString ?? "N/S")")
            }
        default:
            // If you would like to listen for any other ad event, see our Google IMA Ads BPA.
            break
        }
    }
}
