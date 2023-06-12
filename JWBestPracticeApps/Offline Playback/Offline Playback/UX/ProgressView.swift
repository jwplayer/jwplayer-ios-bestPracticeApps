//
//  ProgressView.swift
//  JWPlayerKitDemoApp
//
//  Created by Stephen Seibert on 5/22/23.
//  Copyright © 2023 JW Player. All rights reserved.
//

import Foundation
import UIKit

/**
 This is a custom progress bar used to display download progress in our UITableViewCell.
 */
class ProgressView: UIView {
    private let progressView = UIView()
    private let label = UILabel()
    
    /// When set, this progress is reflected in the view
    /// as both text and a colored bar.
    var progress: Double = 0 {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        
        addSubview(progressView)
        addSubview(label)
        
        progressView.backgroundColor = .blue
        label.frame = self.bounds
        label.textColor = .white
        label.textAlignment = .center
        
        update()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = self.bounds
        update()
    }
    
    /// Updates the progress bar and the pecentage text.
    private func update() {
        let progress: CGFloat = CGFloat(self.progress)
        let width = progress * bounds.width
        let progressFrame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
        progressView.frame = progressFrame
        
        label.text = "\(Int(progress * 100.0))%"
    }
}
