//
//  ErrorView.swift
//  Custom UI
//
//  Created by Stephen Seibert on 4/10/23.
//

import Foundation
import UIKit

/// This view is the interface displayed when an advertisement is playing.
class ErrorView: XibView {
    /// This view loads `ErrorView.xib`
    override var xibName: String { "ErrorView" }
    
    @IBOutlet var textLabel: UILabel?
    
    func setError(code: UInt, message: String) {
        textLabel?.text = "Error \(code)\n\(message)"
    }
}
