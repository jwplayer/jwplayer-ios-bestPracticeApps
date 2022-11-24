//
//  ViewController.swift
//  DRM Fairplay
//
//  Created by David Almaguer on 06/08/21.
//

import UIKit
import JWPlayerKit

class ViewController: JWPlayerViewController,
                      JWDRMContentKeyDataSource {
    
    /// All inputs required for the FairPlay DRM process (the "App" in figure 1-2 of [FairPlay Streaming Overview.pdf](https://developer.apple.com/streaming/fps/FairPlayStreamingOverview.pdf),
    /// page 6) are prefetched and prepared ahead of time, and briefly stored in this struct for use in the content
    /// key protocol's handlers.
    var drmProperties: DRMContentKeyRequestInputs?

    /// Composed of the media ID, DRM policy ID, and a JWT generated from the two IDs + the property's client secret.
    var signedVideoURL: URL {
        guard var mutableUrl = URL(string: "https://cdn.jwplayer.com/v2/")
        else { fatalError("App demo failed on: line \(#line)") }
        
        mutableUrl.append(path: "media/\(JWTestAsset.mediaId)")
        mutableUrl.append(path: "drm/\(JWTestAsset.policyId)")
        
        // FIXME: This can and should be replaced with your preferred JWT generation method.
        let token = TokenGenerator.createToken(
            forMediaId: JWTestAsset.mediaId,
            policyId: JWTestAsset.policyId,
            expiration: 3600
        )
        
        let tokenParam = URLQueryItem(name: "token", value: token)
        mutableUrl.append(queryItems: [tokenParam])
        
        return mutableUrl
    }
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Task is required to use await/async in viewDidLoad
        Task {
            drmProperties = try await prefetchDRMData(protectedSource: signedVideoURL)
            guard let drmProperties else { fatalError("App demo failed on: line \(#line)") }
            self.setUpPlayer(withDRMProtectedURL: drmProperties.videoEndpoint)
        }
    }
    
    /**
     Sets up the player with a DRM configuration.
     */
    private func setUpPlayer(withDRMProtectedURL videoUrl: URL) {
        // Open a do-catch block to catch possible errors with the builders.
        do {
            // First, use the JWPlayerItemBuilder to create a JWPlayerItem that will be used by the player configuration.
            let playerItem = try JWPlayerItemBuilder()
                .file(videoUrl)
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
        let uuidData = DRMContentKeyRequestInputs.contentUUID.data(using: .utf8)
        handler(uuidData)
    }

    /**
     When called, this delegate method requests an Application Certificate binary which must be passed through the completion block.
     - note: The Application Certificate must be encoded with the X.509 standard with distinguished encoding rules (DER). It is obtained when registering an FPS playback app with Apple, by supplying an X.509 Certificate Signing Request linked to your private key.
     */
    func appIdentifierForURL(_ url: URL, completionHandler handler: @escaping (Data?) -> Void) {
        guard let drmProperties else {
            handler(nil)
            return
        }
        handler(drmProperties.appCertificateData)
    }

    /**
     When the key request is ready, this delegate method provides the key request data (SPC - Server Playback Context message) needed to retrieve the Content Key Context (CKC) message from your key server. The CKC message must be returned via the completion block under the response parameter.

     After your app sends the request to the server, the FPS code on the server sends the required key to the app. This key is wrapped in an encrypted message. Your app provides the encrypted message to the JWPlayerKit. The JWPlayerKit unwraps the message and decrypts the stream to enable playback on an iOS device.

     - note: For resources that may expire, specify a renewal date and the content-type in the completion block.
     */
    func contentKeyWithSPCData(_ spcData: Data, completionHandler handler: @escaping (Data?, Date?, String?) -> Void) {
        guard let drmProperties
        else { fatalError("App demo failed on: line \(#line)") }

        var ckcRequest        = URLRequest(url: drmProperties.spcProcessEndpoint)
        ckcRequest.httpMethod = "POST"
        ckcRequest.httpBody   = spcData
        ckcRequest.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        Task {
            let (data, response) = try await URLSession.shared.data(for: ckcRequest)
          
            // handle error response
            guard response.httpStatusCode == 200
            else {
                handler(nil, nil, nil)
                throw DemoError.statusCode(line: #line)
            }

            // happy path
            handler(data, nil, nil)
        }
    }
}

// MARK: Helpers
// Keeping the code clean and organized.

extension ViewController {
    /// Get all the endpoints generated and store as state (briefly) so the intent of the drm callback
    /// methods is self-documenting.
    func prefetchDRMData(protectedSource sourceURL: URL) async throws -> DRMContentKeyRequestInputs {
        // 1. URLSession fetch, and response handling
        let (data, response) = try await URLSession.shared.data(from: sourceURL)

        guard response.httpStatusCode == 200
        else { throw DemoError.statusCode(line: #line) }
        
        let jsonResponse = try newJSONDecoder().decode(DeliveryAPI.self, from: data)
        
        guard
            // 2. Find the drm object mapped from the response...
            let drmItem = jsonResponse.playlist[0].sources.first(where: { $0.drm.fairplay != nil }),
            // 3. ...then unpack the certificate and spc urls.
            let certUrl = drmItem.drm.fairplay?.certificateURL.toURL(),
            let spcUrl  = drmItem.drm.fairplay?.processSpcURL
        else { fatalError("App demo failed on: line \(#line)") }
                
        let (certData, certResponse) = try await URLSession.shared.data(from: certUrl)
        
        guard certResponse.httpStatusCode == 200
        else { throw DemoError.statusCode(line: #line) }

        // 4. Finally, with all the required endpoints/data in hand, return the object to hold
        // them all for later retrieval by the DRM delegate methods.
        return DRMContentKeyRequestInputs(
            videoEndpoint: drmItem.file,
            spcProcessEndpoint: spcUrl,
            appCertificateData: certData
        )
    }
}

/// For non-fatal errors.
enum DemoError: Error {
    case statusCode(line: Int)
}

/// Initializes with the inputs the developer/customer has at hand for easy usage in the DRM delegate methods.
struct DRMContentKeyRequestInputs {
    let videoEndpoint: URL
    let spcProcessEndpoint:  URL
    let appCertificateData: Data
    static let contentUUID = "content-uuid"
    
    init(videoEndpoint ve: String, spcProcessEndpoint spe: String, appCertificateData: Data) {
        guard
            let videoEndpoint      = ve.toURL(),
            let spcProcessEndpoint = spe.toURL()
        else { fatalError("App demo failed on: line \(#line)") }
        
        self.videoEndpoint      = videoEndpoint
        self.spcProcessEndpoint = spcProcessEndpoint
        self.appCertificateData = appCertificateData
    }
}

// MARK: Sugar
extension String {
    func toURL() -> URL? { URL(string: self) }
}

extension URLResponse {
    private var asHTTPURLResponse: HTTPURLResponse? { self as? HTTPURLResponse }
    /// - returns: The status code if applicable, otherwise `-1`.
    var httpStatusCode: Int { (asHTTPURLResponse?.statusCode) ?? -1 }
}
