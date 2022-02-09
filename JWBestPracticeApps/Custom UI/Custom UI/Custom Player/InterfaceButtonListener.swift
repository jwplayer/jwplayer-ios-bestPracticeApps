//
//  InterfaceButtonListener.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation

/// Constants representing buttons within our interfaces.
enum InterfaceButton {
    /// The play button.
    case play
    /// The pause button.
    case pause
    /// The button requesting to enter full screen mode.
    case enterFullScreen
    /// The button requesting to exit full screen mode.
    case exitFullScreen
    /// The button requesting to skip the current advertisement.
    case skipAd
    /// The button requesting to learn more about what is being advertised.
    case learnMore
}

/// This protocol is conformed to by classes which listen for button presses.
/// In this example, `PlayerViewController` listens for the button taps.
protocol InterfaceButtonListener: AnyObject {
    /**
     This method is called when a button is tapped.
     - parameter button: A constant denoting what button was tapped.
     */
    func interfaceButtonTapped(_ button: InterfaceButton)
}
