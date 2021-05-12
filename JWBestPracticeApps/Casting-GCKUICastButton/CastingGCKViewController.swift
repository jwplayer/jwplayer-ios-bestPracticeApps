//
//  CastingGCKViewController.swift
//  Casting-GCKUICastButton
//
//  Created by Michael Salvador on 5/12/21.
//  Copyright © 2021 Karim Mourra. All rights reserved.
//

import Foundation
import GoogleCast

class CastingGCKViewController: BasicVideoViewController, JWCastingDelegate {

    var castController: JWCastController? = nil
    var castingButton: UIButton? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor.gray

        // Setup JWCastController object
        setupCastController()
        setUpCastButton()
    }

    func setupCastController() {
        guard let player = self.player else { return }

        let castController = JWCastController(player: player)
        castController.chromeCastReceiverAppID = kGCKDefaultMediaReceiverApplicationID
        castController.delegate = self
        castController.scanForDevices()
        self.castController = castController
    }

    func setUpCastButton() {
        self.castingButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.castingButton?.tintColor = UIColor.white
        guard let castingButton = castingButton else {
            return
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castingButton)
    }

    // MARK: - JWCastingDelegate

    func onCastingDevicesAvailable(_ devices: [JWCastingDevice]) {

    }

    func onConnected(to device: JWCastingDevice) {
        self.castController?.cast()
    }

    func onConnectionRecovered() {
        self.castController?.cast()
    }
}
