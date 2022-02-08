//
//  PlayerViewManager.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import UIKit
import JWPlayerKit

enum PlayerInterface {
    case none
    case video
    case ads
}

class PlayerViewManager {
    let container = UIView()
    let playerView = JWPlayerView()
    
    private var currentInterface: XibView? {
        willSet {
            currentInterface?.removeFromSuperview()
        }
        didSet {
            guard let currentInterface = currentInterface else {
                return
            }

            container.addSubview(currentInterface)
            currentInterface.fillSuperview()
        }
    }
    
    var interface: PlayerInterface = .none {
        didSet {
            guard oldValue != interface else {
                return
            }
            
            changeInterface(to: interface)
        }
    }
    
    var state: JWPlayerState = .idle {
        didSet {
            guard oldValue != state else {
                return
            }
            
            onStateChanged()
        }
    }
    
    init() {
        container.addSubview(playerView)
        playerView.fillSuperview()
    }
    
    func setController(_ controller: UIViewController) {
        container.removeFromSuperview()
        controller.view.addSubview(container)
        container.fillSuperview()
    }
    
    private func changeInterface(to interface: PlayerInterface) {
        switch interface {
        case .none:
            currentInterface = nil
        case .video:
            currentInterface = VideoControlsView(frame: container.bounds)
        case .ads:
            currentInterface = AdControlsView(frame: container.bounds)
        }
    }
    
    private func onStateChanged() {
        
    }
}
