//
//  PlayerViewManager.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import UIKit
import JWPlayerKit

/// Constants representing our different interfaces.
enum PlayerInterface: Equatable {
    /// No interface at all. If used, no interface is shown over the video.
    case none
    /// The video interface represented by `VideoControlsView` and `VideoControls.xib`.
    case video
    /// The video interface represented by `AdControlsView` and `AdControls.xib`.
    case ads
    /// The video interface represented by `ErrorView` and `ErrorView.xib`
    /// This takes an error code (`UInt`) and a message (`String`)
    case error(UInt, String)
    
    /// We need to define the equivalency operator because `.error` takes arguments.
    static func ==(lhs: PlayerInterface, rhs: PlayerInterface) -> Bool {
        switch lhs {
        case .ads:
            return rhs == .ads
        case .none:
            return rhs == .none
        case .video:
            return rhs == .video
        case .error(let code, _):
            switch rhs {
            case .error(let rhsCode, _):
                return rhsCode == code
            default:
                return false
            }
        }
    }
}

/// Constants denoting whether we are in full screen mode or not.
enum PlayerWindowState {
    /// The window is in full screen mode.
    case fullscreen
    /// The window is not in full screen mode, and is embedded in another view hierarchy as a smaller window.
    case normal
}

/// This class is responsible for managing the view hierarchy.
/// The `PlayerViewController` communicates with this class, updating it on the state of the player.
/// * note: All interactions with this class need to be done on the main thread since this manager interacts with UI elements.
class PlayerViewManager {
    /// This container is embedded in the currently active view controller.
    /// Having this container makes it easy to transplant our entire view hierarchy from `PlayerViewController` to `FullScreenPlayerViewController` when
    /// entering full screen mode, or back to `PlayerViewController` when dismissing full screen mode.
    let container = UIView()
    
    /// Our player view. This displays the video, and gives us access to the player via the `JWPlayer` object.
    /// It is embedded in the container behind all interfaces.
    let playerView = JWPlayerView()
    
    /// The classes which listens for button taps. In this example, that is `PlayerViewController`.
    weak var buttonListener: InterfaceButtonListener? {
        didSet {
            currentInterface?.buttonListener = buttonListener
        }
    }
    
    /// This is a reference to the currently displayed interface.
    private var currentInterface: XibView? {
        willSet {
            // Before displaying a new interface, remove the old one from the view hierarchy.
            currentInterface?.removeFromSuperview()
        }
        didSet {
            guard let currentInterface = currentInterface else {
                return
            }

            // If a valid interface was set, add it to the container so it
            // overlaps the `JWPlayerView`.
            container.addSubview(currentInterface)
            currentInterface.fillSuperview()
            
            // Set the state variables.
            // These states must be set in the newly displayed interface.
            currentInterface.buttonListener = buttonListener
            currentInterface.playerState = state
            currentInterface.windowState = windowState
            currentInterface.currentTime = currentTime
        }
    }
    
    /// The currently desired interface.
    var interface: PlayerInterface = .none {
        didSet {
            guard oldValue != interface else {
                return
            }
            
            switch interface {
            case .none:
                // If no interface is desired, we remove the current interface.
                currentInterface = nil
            case .video:
                // If the video interface is desired, we create the interface.
                currentInterface = VideoControlsView(frame: container.bounds)
            case .ads:
                // If the advertising interface is desired, we create the interface.
                currentInterface = AdControlsView(frame: container.bounds)
            case .error(let code, let message):
                // If the error interface is desired, we create the interface.
                let errorView = ErrorView(frame: container.bounds)
                errorView.setError(code: code, message: message)
                currentInterface = errorView
            }
        }
    }
    
    /// The current state of the player.
    var state: JWPlayerState = .idle {
        didSet {
            guard oldValue != state else {
                return
            }
            
            currentInterface?.playerState = state
        }
    }
    
    /// The current window state, e.g. whther or not we are in full screen mode.
    var windowState: PlayerWindowState = .normal {
        didSet {
            guard oldValue != windowState else {
                return
            }
            
            currentInterface?.windowState = windowState
        }
    }
    
    /// The current position and duration of the content. This is not updated when in an advertisement.
    var currentTime: JWTimeData? {
        didSet {
            currentInterface?.currentTime = currentTime
        }
    }
    
    /// We initialize this manager by adding the playerView to the container.
    init() {
        container.addSubview(playerView)
        playerView.fillSuperview()
    }
    
    /**
     This sets the currently active view controller.
     - parameter controller: The currently active view controller.
     */
    func setController(_ controller: UIViewController) {
        // When a new view controller is specified, we remove the view hierarchy from
        // it and add it to the new view controller.
        container.removeFromSuperview()
        controller.view.addSubview(container)
        container.fillSuperview()
    }
}
