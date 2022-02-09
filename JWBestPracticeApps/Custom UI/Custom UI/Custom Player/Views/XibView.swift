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
 All views which are defined by a XIB file use this superclass. This superclass should not be used on its own.
 */
class XibView: UIView {
    @IBOutlet weak var contentView: UIView!
    
    open var xibName: String { "" }
    
    weak var buttonListener: InterfaceButtonListener?
    
    var playerState: JWPlayerState = .idle {
        didSet {
            guard oldValue != playerState else {
                return
            }
            
            onPlayerStateChanged()
        }
    }
    
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
     Initial setup of the view.
     */
    open func setupView() {
        guard load(xib: xibName, owner: self) != nil, contentView != nil else {
            print("Failed to load XIB with name: '\(xibName).xib'")
            return
        }

        addSubview(contentView)
        contentView.fillSuperview()
    }
    
    /**
     Loads the xib the value represents.
     - parameter owner: The object which will own the loaded xib.
     - returns: An array of high level objects in the xib file.
     */
    private func load(xib name: String, owner: Any) -> [Any]? {
        let objs = Bundle.main.loadNibNamed(name, owner: owner, options: nil)
        return objs
    }
    
    open func onPlayerStateChanged() {
        
    }
}
