//
//  ViewController.swift
//  DRM Fairplay
//
//  Created by David Almaguer on 06/08/21.
//

import UIKit
import JWPlayerKit
import vudrmFairPlaySDK

private let VUDRMCertificateEndpoint = "INSERT_CERTIFICATE_URL"
private let VUDRMVideoEndpoint = "INSERT_CONTENT_URL"
private let VUDRMToken = "INSERT_TOKEN"


class ViewController: JWPlayerViewController,
                      JWDRMContentKeyDataSource {

    var contentUUID: String?
    var contentID: String?
    var licenseUrl: String?
    var drm: vudrmFairPlaySDK?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the player.
        setUpPlayer()
    }

    /**
     Sets up the player with a DRM configuration.
     */
    private func setUpPlayer() {
        // Open a do-catch block to catch possible errors with the builders.
        do {
            let videoUrl = URL(string:VUDRMVideoEndpoint)!

            // First, use the JWPlayerItemBuilder to create a JWPlayerItem that will be used by the player configuration.
            let playerItem = try JWPlayerItemBuilder()
                .file(videoUrl)
                .build()

            // Second, create a player config with the created JWPlayerItem.
            let config = try JWPlayerConfigurationBuilder()
                .playlist([playerItem])
                .autostart(true)
                .build()

            // Third, set the data source class. This class conforms to JWDRMContentKeyDataSource, and defines methods which affect DRM.
            player.contentKeyDataSource = self

            // Lastly, use the created JWPlayerConfiguration to set up the player.
            player.configurePlayer(with: config)
        } catch {
            // Builders can throw, so be sure to handle the build failures.
            print(error.localizedDescription)
            return
        }
    }

    // MARK: JWDRMContentKeyDataSource

    /**
     When called, this delegate method requests the identifier for the protected content to be passed through the delegate method's completion block.
     */
    func contentIdentifierForURL(_ url: URL, completionHandler handler: @escaping (Data?) -> Void) {
        guard let uuid = url.absoluteString.split(separator: ";").last,
              let uuidData = uuid.data(using: .utf8) else {
            handler(nil)
            return
        }
        self.contentUUID = String(uuid)
        self.licenseUrl = uuid.replacingOccurrences(of: "skd", with: "https")
        self.contentID = url.lastPathComponent
        handler(uuidData)
    }


    /**
     When called, this delegate method requests an Application Certificate binary which must be passed through the completion block.
     - note: The Application Certificate must be encoded with the X.509 standard with distinguished encoding rules (DER). It is obtained when registering an FPS playback app with Apple, by supplying an X.509 Certificate Signing Request linked to your private key.
     */
    func appIdentifierForURL(_ url: URL, completionHandler handler: @escaping (Data?) -> Void) {
        print("url: \(url)")

        // obtain application Id / Application Certificate here.
        do {
            
            self.drm = vudrmFairPlaySDK()
            let applicationCertificate = try drm?.requestApplicationCertificate(token: VUDRMToken, contentID: contentID!)
            
            let applicationId: Data = applicationCertificate!
            
            handler(applicationId)
        } catch {
            let message = ["appIdentifierForURL": "Unexpected error: \(error)."]
            print(message)
        }
    }

    /**
     When the key request is ready, this delegate method provides the key request data (SPC - Server Playback Context message) needed to retrieve the Content Key Context (CKC) message from your key server. The CKC message must be returned via the completion block under the response parameter.

     After your app sends the request to the server, the FPS code on the server sends the required key to the app. This key is wrapped in an encrypted message. Your app provides the encrypted message to the JWPlayerKit. The JWPlayerKit unwraps the message and decrypts the stream to enable playback on an iOS device.

     - note: For resources that may expire, specify a renewal date and the content-type in the completion block.
     */
    func contentKeyWithSPCData(_ spcData: Data, completionHandler handler: @escaping (Data?, Date?, String?) -> Void) {
        
        do {
            // Send SPC to Key Server and obtain CKC - renewal value must currently be 0 with JWPlayerSDK.
            let ckcData = try self.drm!.requestContentKeyFromKeySecurityModule(spcData: spcData, token: VUDRMToken, assetID: contentID!, licenseURL: licenseUrl!, renewal: 0)
            
            let key: Data? = ckcData // obtain key here from server by providing the request.
            let renewalDate: Date? // (optional)
            renewalDate = nil // Not currently tested with VUDRM
            let contentType = "application/octet-stream" // (optional)
            
            handler(key, renewalDate, contentType)
        } catch {
            let message = ["contentKeyWithSPCData": "Unexpected error: \(error)."]
            print(message)
        }
    }
}
