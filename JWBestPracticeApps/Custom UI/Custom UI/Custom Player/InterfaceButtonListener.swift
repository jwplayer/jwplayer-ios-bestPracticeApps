//
//  InterfaceButtonListener.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation

enum InterfaceButton {
    case play
    case pause
    case maximizeWindow
    case minimizeWindow
    case skipAd
    case learnMore
}

protocol InterfaceButtonListener: AnyObject {
    func interfaceButtonTapped(_ button: InterfaceButton)
}
