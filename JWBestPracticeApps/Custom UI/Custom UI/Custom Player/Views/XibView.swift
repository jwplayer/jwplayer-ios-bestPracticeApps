//
//  XibView.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import UIKit
import JWPlayerKit

/**
 All views which are defined by a XIB file use this superclass. This superclass should not be instantiated on its own.
 */
class XibView: UIView {
    /// A reference to the base view. This is embedded within this view.
    @IBOutlet weak var contentView: UIView!
    
    /// The name of the xib. This should be overridden by subclasses.
    open var xibName: String { "" }
    
    /// The class listening for button presses. This listener is informed when the user taps a button.
    weak var buttonListener: InterfaceButtonListener?
    
    /// The current state of the player. This can be observed to change an interface based on the state of the player.
    var playerState: JWPlayerState = .idle
    
    /// The current window state of the player.
    /// This can be observed to change an interface based on the state of the player's window mode, whether it is full screen or not.
    var windowState: PlayerWindowState = .normal
    
    /// The current position and duration of the player's media content.
    /// - note: This is not updated for advertisements, only media content.
    var currentTime: JWTimeData?
    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    /**
     Initial setup of the view. It loades the specified xib, and embeds it in this view.
     */
    open func setupView() {
        guard load(xib: xibName, owner: self) != nil, contentView != nil else {
            print("Failed to load XIB with name: '\(xibName).xib'")
            return
        }

        // Embed the xib's root view within this view, and
        // force it to the size of this view.
        addSubview(contentView)
        contentView.fillSuperview()
    }
    
    /**
     Loads a xib file.
     - parameter name: The name of the xib to load.
     - parameter owner: The object which will own the loaded xib.
     - returns: An array of high level objects in the xib file.
     */
    private func load(xib name: String, owner: Any) -> [Any]? {
        let objs = Bundle.main.loadNibNamed(name, owner: owner, options: nil)
        return objs
    }
}
