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

enum PlayerWindowState {
    case fullscreen
    case normal
}

class PlayerViewManager {
    let container = UIView()
    let playerView = JWPlayerView()
    
    weak var buttonListener: InterfaceButtonListener? {
        didSet {
            currentInterface?.buttonListener = buttonListener
        }
    }
    
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
            currentInterface.buttonListener = buttonListener
            currentInterface.playerState = state
            currentInterface.windowState = windowState
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
            
            currentInterface?.playerState = state
        }
    }
    
    var windowState: PlayerWindowState = .normal {
        didSet {
            guard oldValue != windowState else {
                return
            }
            
            currentInterface?.windowState = windowState
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
}
