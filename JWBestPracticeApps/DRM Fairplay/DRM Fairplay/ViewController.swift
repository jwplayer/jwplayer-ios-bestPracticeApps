//
//  ViewController.swift
//  DRM Fairplay
//
//  Created by David Almaguer on 06/08/21.
//

import UIKit
import JWPlayerKit
// For more info on signed URLs: https://docs.jwplayer.com/platform/docs/protection-studio-drm-generate-a-signed-content-url-for-drm-playback
private let signedURL = "{YOUR_SIGNED_URL}"

class ViewController: JWPlayerViewController,
                      JWDRMContentKeyDataSource {

    /// The locator for the certificate
    var certificateURLStr: String?
    /// The server playback context locator
    /// This is used to request the content key from the Key Server Module
    var processSPCURLStr: String?
    // The video URL that we get from decoding the playlist
    var videoURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        createPlaylist(from: URL(string: signedURL)!)
    }
    
    private func createPlaylist(from url: URL) {
        let urlRequest = URLRequest(url: url)
        let semaphore = DispatchSemaphore(value: 0)
        // Signed URLs locate the playlist from JWPlayer's CDN, we then try to decode the playlist into a DRMPlaylist.
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            defer { semaphore.signal() }
            guard let self = self else {
                return
            }

            guard let data = data else {
                print(String(describing:error?.localizedDescription))
                return
            }
            // Try to decode the response into a DRM playlist.
            do {
                let drmPlaylist = try JSONDecoder().decode(DRMPlaylist.self, from: data)
                // The playlist item has several sources we want to use the m3u8 file, for that we use the first source that has an mpegurl type.
                guard let source = drmPlaylist.playlist.first?.sources.first(where: { $0.type == "application/vnd.apple.mpegurl"}) else {
                    return
                }
                let drm = source.drm
                // We get the certificate URL from the Fairplay object
                self.certificateURLStr = drm.fairplay?.certificateURL
                // We get the processSPC from the Fairplay object
                self.processSPCURLStr = drm.fairplay?.processSpcURL
                self.videoURL = source.file
            } catch {
                // Do something with the error.
                print(error.localizedDescription)
            }
        }
        task.resume()
        semaphore.wait()
        if let video = videoURL, let videoURL = URL(string: video) {
            self.setUpPlayer(with: videoURL)
        }
    }

    /**
     Sets up the player with a DRM configuration.
     */
    private func setUpPlayer(with videoURL: URL) {
        // Open a do-catch block to catch possible errors with the builders.
        do {
            // First, use the JWPlayerItemBuilder to create a JWPlayerItem that will be used by the player configuration.
            let playerItem = try JWPlayerItemBuilder()
                .file(videoURL)
                .build()

            // Second, create a player config with the created JWPlayerItem.
            let config = try JWPlayerConfigurationBuilder()
                .playlist(items: [playerItem])
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
        let data = url.host?.data(using: .utf8)
        handler(data)
    }


    /**
     When called, this delegate method requests an Application Certificate binary which must be passed through the completion block.
     - note: The Application Certificate must be encoded with the X.509 standard with distinguished encoding rules (DER). It is obtained when registering an FPS playback app with Apple, by supplying an X.509 Certificate Signing Request linked to your private key.
     */
    func appIdentifierForURL(_ url: URL, completionHandler handler: @escaping (Data?) -> Void) {
        guard let certificateURLStr = certificateURLStr, let certificateURL = URL(string: certificateURLStr) else {
            return
        }
        let request = URLRequest(url: certificateURL)
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            handler(data)
        }
        task.resume()
    }

    /**
     When the key request is ready, this delegate method provides the key request data (SPC - Server Playback Context message) needed to retrieve the Content Key Context (CKC) message from your key server. The CKC message must be returned via the completion block under the response parameter.

     After your app sends the request to the server, the FPS code on the server sends the required key to the app. This key is wrapped in an encrypted message. Your app provides the encrypted message to the JWPlayerKit. The JWPlayerKit unwraps the message and decrypts the stream to enable playback on an iOS device.

     - note: For resources that may expire, specify a renewal date and the content-type in the completion block.
     */
    func contentKeyWithSPCData(_ spcData: Data, completionHandler handler: @escaping (Data?, Date?, String?) -> Void) {
        guard let processSPCURLStr = processSPCURLStr, let processSPCURL = URL(string: processSPCURLStr) else {
            return
        }
        var request = URLRequest(url: processSPCURL)
        request.httpMethod = "POST"
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-type")
        request.httpBody = spcData

        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            handler(data, nil, "application/octet-stream")
        }
        task.resume()
    }
}
