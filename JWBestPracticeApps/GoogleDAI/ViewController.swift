//
//  ViewController.swift
//  GoogleDAI
//
//  Created by Stephen Seibert  on 3/30/20.
//  Copyright © 2020 Karim Mourra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var player: JWPlayerController!

    private let fallbackContentUrl = "http://cdn-videos.akamaized.net/btv/desktop/fastly/us/live/primary.m3u8"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the DAI Config
        let daiConfig = JWGoogimaDaiConfig(assetKey: "sN_IYUG8STe1ZzhIIE_ksA")

        // Create the Ad Config
        let adConfig = JWAdConfig()
        adConfig.client = .googimaDAI
        adConfig.googimaDaiSettings = daiConfig

        // Initialize the JWConfig and create the JWPlayerController
        // The content URL supplied here will be used if the DAI video fails to load.
        let config = JWConfig(contentURL: fallbackContentUrl)
        config.advertising = adConfig

        player = JWPlayerController(config: config)
        constrainPlayerToView()
    }

    private func constrainPlayerToView() {
        if let containerView = view,
            let playerView = player?.view {
            containerView.addSubview(playerView)
            // Turn off translatesAutoresizingMaskIntoConstraints property to use Auto Layout to dynamically calculate the size and position
            playerView.translatesAutoresizingMaskIntoConstraints = false
            // Add constraints to center the playerView
            playerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            playerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            playerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            playerView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        }
    }
}

