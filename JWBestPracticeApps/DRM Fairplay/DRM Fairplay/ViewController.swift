//
//  ViewController.swift
//  DRM Fairplay
//
//  Created by David Almaguer on 06/08/21.
//

import UIKit
import JWPlayerKit

/// Appears to expire after a couple of minutes. Refresh using instructions in ticket.
fileprivate let token = """
    eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyZXNvdXJjZSI6Ii92Mi9tZWRpYS9reWJvN3g3Yi9kcm0vYWlVZWhJQVMiLCJleHAiOjE2Njg0ODk0Mzl9.XCXdXSESbZSA0Gq7lLifB8glsI2gZgAtIYWGM2zQKeA
    """

fileprivate var JWDRM_VideoEndpoint: String?
fileprivate var JWDRM_CertificateEndpoint: String?
fileprivate var JWDRM_SPCProcessEndpoint:  String?
fileprivate var JWDRM_AppCertificateData: Data?

class ViewController: JWPlayerViewController,
                      JWDRMContentKeyDataSource {

    var contentUUID = "content-uuid"
    let videoUrl = "https://cdn.jwplayer.com/v2/media/kybo7x7b/drm/aiUehIAS?token=\(token)"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            try await prefetchDRMData(protectedSource: videoUrl)
            try await prefetchAppCertificate()
            
            guard prefetchedPropertiesDoExist()
            else { fatalError("App demo failed on: line \(#line)") }
            
            self.setUpPlayer()
        }
    }
    
    /// Checks to make sure the async operations populated the values successfully.
    private func prefetchedPropertiesDoExist() -> Bool {
        ([
            JWDRM_VideoEndpoint,
            JWDRM_CertificateEndpoint,
            JWDRM_SPCProcessEndpoint,
            JWDRM_AppCertificateData,
        ] as [Any?])
            .allSatisfy({ $0 != nil })
    }
    
    /**
     Sets up the player with a DRM configuration.
     */
    private func setUpPlayer() {
        // Open a do-catch block to catch possible errors with the builders.
        do {
            let videoUrl = URL(string: JWDRM_VideoEndpoint!)!

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
        print(#function)

        let uuidData = contentUUID.data(using: .utf8)
        handler(uuidData)
    }


    /**
     When called, this delegate method requests an Application Certificate binary which must be passed through the completion block.
     - note: The Application Certificate must be encoded with the X.509 standard with distinguished encoding rules (DER). It is obtained when registering an FPS playback app with Apple, by supplying an X.509 Certificate Signing Request linked to your private key.
     */
    func appIdentifierForURL(_ url: URL, completionHandler handler: @escaping (Data?) -> Void) {
        print(#function)
        print("url: \(url)")
        
        guard let appIdData = JWDRM_AppCertificateData
        else {
            handler(nil)
            return
        }
        handler(appIdData)
    }

    /**
     When the key request is ready, this delegate method provides the key request data (SPC - Server Playback Context message) needed to retrieve the Content Key Context (CKC) message from your key server. The CKC message must be returned via the completion block under the response parameter.

     After your app sends the request to the server, the FPS code on the server sends the required key to the app. This key is wrapped in an encrypted message. Your app provides the encrypted message to the JWPlayerKit. The JWPlayerKit unwraps the message and decrypts the stream to enable playback on an iOS device.

     - note: For resources that may expire, specify a renewal date and the content-type in the completion block.
     */
    func contentKeyWithSPCData(_ spcData: Data, completionHandler handler: @escaping (Data?, Date?, String?) -> Void) {
        print(#function)

        guard
            let spcEndpoint = JWDRM_SPCProcessEndpoint,
            let licenseApiPath = URL(string: spcEndpoint)
        else { fatalError("App demo failed on: line \(#line)") }
        
        var ckcRequest = URLRequest(url: licenseApiPath)
        ckcRequest.httpMethod = "POST"
        ckcRequest.httpBody = spcData
        ckcRequest.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        Task {
            let (data, response) = try await URLSession.shared.data(for: ckcRequest)
            guard (200...299).contains((response as? HTTPURLResponse)!.statusCode) else {
                handler(nil, nil, nil)
                throw DemoError.statusCode(line: #line)
            }

            handler(data, nil, nil)
        }
    }
}

// MARK: Helpers

extension ViewController {
    /// Get all the endpoints generated and set, so the request can run smoothly.
    func prefetchDRMData(protectedSource: String) async throws {
        print(#function)
        
        // 1. URLRequest composition
        guard let sourceURL = URL(string: protectedSource)
        else { fatalError("App demo failed on: line \(#line)") }
        
        var request = URLRequest(url: sourceURL,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10)
        request.allHTTPHeaderFields = ["Accept": "application/json; charset=utf-8"]
        
        print("About to fetch with request: \n\(request.description)")
        
        // 2. URLSession fetch and response handling
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw DemoError.statusCode(line: #line)
        }
        let jsonData = try newJSONDecoder().decode(DeliveryAPI.self, from: data)
        
        // 3a. Get the index of a source with a "fairplay" element.
        guard let fairPlayIndex = jsonData.playlist[0].sources
            .firstIndex(where: { $0.drm.fairplay != nil })
        else { fatalError("App demo failed on: line \(#line)") }
        
        // 3b. Assign relevant fields from fetched DeliveryAPI for our stream config
        let drmItem = jsonData.playlist[0].sources[fairPlayIndex]
        JWDRM_CertificateEndpoint = drmItem.drm.fairplay?.certificateURL
        JWDRM_VideoEndpoint       = drmItem.file
        JWDRM_SPCProcessEndpoint  = drmItem.drm.fairplay?.processSpcURL
        
        print("DRM-Log certificate -  \(JWDRM_CertificateEndpoint!)")
        print("DRM-Log video -  \(JWDRM_VideoEndpoint!)")
        print("DRM-Log spc_process -  \(JWDRM_SPCProcessEndpoint!)")
    }
    
    func prefetchAppCertificate() async throws {
        guard
            let certEndpoint = JWDRM_CertificateEndpoint,
            let certUrl = URL(string: certEndpoint)
        else { fatalError("App demo failed on: line \(#line)") }
        
        let (data, response) = try await URLSession.shared.data(from: certUrl)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw DemoError.statusCode(line: #line)
        }

        JWDRM_AppCertificateData = data
    }
}

enum DemoError: Error {
    case statusCode(line: Int)
}
