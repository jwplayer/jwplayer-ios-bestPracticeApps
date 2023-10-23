//
//  ViewController.swift
//  Chromecast-GCKUICastButton
//
//  Created by David Perez on 30/09/21.
//

import UIKit
import JWPlayerKit
import GoogleCast

class ViewController: JWPlayerViewController {
    
    private let videoUrlString = "https://cdn.jwplayer.com/videos/CXz339Xh-sJF8m8CA.mp4"
    private let posterUrlString = "https://cdn.jwplayer.com/thumbs/CXz339Xh-720.jpg"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's background color to black for better contrast.
        view.backgroundColor = .black

        // Set up the player.
        setUpPlayer()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        // Sets up cast button on parent's navigation controller.
        setUpCastButton()
    }

    /**
     Sets up the player with a simple configuration.
     */
    private func setUpPlayer() {
        let videoUrl = URL(string:videoUrlString)!
        let posterUrl = URL(string:posterUrlString)!
        
        do {
            // First, use the JWPlayerItemBuilder to create a JWPlayerItem that will be used by the player configuration.
            let playerItem = try JWPlayerItemBuilder()
                .file(videoUrl)
                .posterImage(posterUrl)
                .build()
            
            // Second, create a player config with the created JWPlayerItem. Add the related config.
            let config = try JWPlayerConfigurationBuilder()
                .playlist(items: [playerItem])
                .autostart(true)
                .build()
            
            // Lastly, use the created JWPlayerConfiguration to set up the player.
            player.configurePlayer(with: config)
        } catch {
            // Handle player item build failure
            print(error.localizedDescription)
            return
        }
    }
    
    /**
     Sets up GCKUICastButton casting button on navigation bar.
     */
    func setUpCastButton(){
        // We initialize the GCKUICastButton and add to the view, for the user to interact with.
        let castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        castButton.tintColor = .white
        // Since this is embedded in a container view, we update the parent's navigation item.
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
    }
    
    // MARK: - JWCastDelegate
    // Optionally, override the following methods to receive and respond to events when casting.
    // Always call the superclass's method when overriding these methods.
    
    
    // Called when a new casting device comes online.
    override func castController(_ controller: JWCastController, devicesAvailable devices: [JWCastingDevice]) {
        super.castController(controller, devicesAvailable: devices)
        print("[JWCastDelegate]: \(devices.count) became available: \(devices)")
    }

    // Called when a successful connection to a casting device is made.
    override func castController(_ controller: JWCastController, connectedTo device: JWCastingDevice) {
        super.castController(controller, connectedTo: device)
        print("[JWCastDelegate]: Connected to device: \(device.identifier)")
    }

    
    // Called when the casting device disconnects.
    override func castController(_ controller: JWCastController, disconnectedWithError error: Error?) {
        super.castController(controller, disconnectedWithError: error)
        
        if let error = error {
            print("[JWCastDelegate]: Casting disconnected from device with error: \"\(error.localizedDescription)\"")
        }
        else {
            print("[JWCastDelegate]: Casting disconnected from device successfully.")
        }
    }

    
    // Called when the connected casting device is temporarily disconnected. Video resumes on the mobile device until connection resumes.
    override func castController(_ controller: JWCastController, connectionSuspendedWithDevice device: JWCastingDevice) {
        super.castController(controller, connectionSuspendedWithDevice: device)
        print("[JWCastDelegate]: Connection suspended with device: \(device.identifier)")
    }

    
    // Called after connection is reestablished following a temporary disconnection. Video resumes on the casting device.
    override func castController(_ controller: JWCastController, connectionRecoveredWithDevice device: JWCastingDevice) {
        super.castController(controller, connectionRecoveredWithDevice: device)
        print("[JWCastDelegate]: Connection recovered with device: \(device.identifier)")
    }

    // Called when an attempt to connect to a casting device is unsuccessful.
    override func castController(_ controller: JWCastController, connectionFailedWithError error: Error) {
        super.castController(controller, connectionFailedWithError: error)
        print("[JWCastDelegate]: Connection failed with error: \(error.localizedDescription)")
    }

    // Called when casting session begins.
    override func castController(_ controller: JWCastController, castingBeganWithDevice device: JWCastingDevice) {
        super.castController(controller, castingBeganWithDevice: device)
        print("[JWCastDelegate]: Casting began with device: \(device.identifier)")
    }

    // Called when an attempt to cast to a casting device is unsuccessful.
    override func castController(_ controller: JWCastController, castingFailedWithError error: Error) {
        super.castController(controller, castingFailedWithError: error)
        print("[JWCastDelegate]: Casting failed with error: \(error.localizedDescription)")
    }

    // Called when a casting session ends.
    override func castController(_ controller: JWCastController, castingEndedWithError error: Error?) {
        super.castController(controller, castingEndedWithError: error)
        
        if let error = error {
            print("[JWCastDelegate]: Casting ended with error: \"\(error.localizedDescription)\"")
        }
        else {
            print("[JWCastDelegate]: Casting ended successfully.")
        }
    }

}


