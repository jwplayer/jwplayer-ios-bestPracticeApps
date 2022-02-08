//
//  UIView.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import UIKit

extension UIView {
    /**
     Adds constraints to the view so that it fills its superview.
     */
    func fillSuperview() {
        guard let _ = self.superview else {
            print("Attempted to enlarge a view to its superview's width and height, without a superview.")
            return
        }

        translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[thisView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["thisView": self])

        let verticalConstraints   = NSLayoutConstraint.constraints(withVisualFormat: "V:|[thisView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["thisView": self])

        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints)
    }
}
