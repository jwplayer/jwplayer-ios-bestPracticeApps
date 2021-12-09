//
//  JWFairPlayDrmViewController.swift
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 9/26/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

import vudrmFairPlaySDK


class JWVUDRMFairPlayViewController: JWBasicVideoViewController, JWDrmDataSource, URLSessionDelegate {

    let encryptedFile = "INSERT_CONTENT_URL"
    let vudrmToken = "INSERT_TOKEN"
    var drm: vudrmFairPlaySDK?
    var contentID: String?
    var licenseUrl: String?
    var parsedAssetID: NSURL?
    var gotURI : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player.drmDataSource = self
    }
    
    override func onReady(_ event: JWEvent & JWReadyEvent) {
        let item = JWPlaylistItem()
        item.file = encryptedFile
        self.player.load([item])
    }
    
    func fetchAppIdentifier(forRequest loadingRequestURL: URL, for encryption: JWEncryption, withCompletion completion: @escaping (Data) -> Void) {
        if encryption == .fairPlay {
            // obtain application Id / Application Certificate here.
            do {
                
                self.drm = vudrmFairPlaySDK()
                let applicationCertificate = try drm?.requestApplicationCertificate(token: vudrmToken, contentID: contentID!)
                
                let applicationId: Data = applicationCertificate!
                
                completion(applicationId)
            } catch {
                let message = ["fetchAppIdentifier": "Unexpected error: \(error)."]
                print(message)
            }
        }
    }
    
    func fetchContentIdentifier(forRequest loadingRequestURL: URL, for encryption: JWEncryption, withCompletion completion: @escaping (Data) -> Void) {
        if encryption == .fairPlay {
            // obtain asset Id / Content Key ID here.
            self.getAssetID(videoUrl: NSURL(string: encryptedFile)!){
                let assetId: String = (self.parsedAssetID?.absoluteString)!
                self.contentID = (self.parsedAssetID?.lastPathComponent)!
                self.licenseUrl = assetId.replacingOccurrences(of: "skd", with: "https")
                let assetIdData = Data(bytes: assetId.cString(using: .utf8)!,
                                       count: assetId.lengthOfBytes(using: .utf8))
                completion(assetIdData)
            }
        }
    }
    
    func fetchContentKey(withRequest requestBytes: Data, for encryption: JWEncryption, withCompletion completion: @escaping (Data, Date?, String?) -> Void) {
        if encryption == .fairPlay {
            
            do {
                
                // Send SPC to Key Server and obtain CKC.
                let ckcData = try self.drm!.requestContentKeyFromKeySecurityModule(spcData: requestBytes, token: vudrmToken, assetID: self.contentID!, licenseURL: licenseUrl!, renewal: 0)
                
                let key: Data? = ckcData // obtain key here from server by providing the request.
                let renewalDate: Date? // (optional)
                let contentType = "application/octet-stream" // (optional)
                
                renewalDate = nil
                
                completion(key!, renewalDate, contentType)
                
            } catch {
                let message = ["fetchContentKey": "Unexpected error: \(error)."]
                print(message)
            }
        }
    }
    
    // MARK: - Helper methods
    
    // Parses the playlist / manifest to retrieve the required Content Key ID, being the 'skd://' value of the "EXT-X-SESSION-KEY" or "EXT-X-KEY". The correct license server URL should be obtained from this value, and the last path component represents the correct Content ID.
    
    func getAssetID (videoUrl: NSURL, completion: @escaping() -> Void) {
        let message = ["getAssetID": "Parsing Content Key ID from manifest with \(videoUrl)"]
        print(message)
        var request = URLRequest(url: videoUrl as URL)
        gotURI = false
        request.httpMethod = "GET"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { [weak self] data, response, _ in
            guard let data = data else { return }
            
            self!.parsePlaylistData(data: data, videoUrl:videoUrl)
            
            while !self!.gotURI! {
                // wait
            }
            completion()
        }
        task.resume()
    }
    
    func parsePlaylistData (data: Data, videoUrl: NSURL) {
        let strData = String(data: data, encoding: .utf8)!
        if strData.contains("EXT-X-SESSION-KEY") || strData.contains("EXT-X-KEY") {
            let start = strData.range(of: "URI=\"")!.upperBound
            let end = strData[start...].range(of: "\"")!.lowerBound
            let keyUrlString = strData[start..<end]
            let keyUrl = URL(string: String(keyUrlString))
            let message = ["getAssetID": "Parsed Content Key ID from manifest: \(keyUrlString)"]
            print(message)
            parsedAssetID = keyUrl as NSURL?
            gotURI = true
        } else {
            // This could be HLS content with variants
            if strData.contains("EXT-X-STREAM-INF") {
                // Prepare the new variant video url last path components
                let start = strData.range(of: "EXT-X-STREAM-INF")!.upperBound
                let end = strData[start...].range(of: ".m3u8")!.upperBound
                let strData2 = strData[start..<end]
                let start2 = strData2.range(of: "\n")!.lowerBound
                let end2 = strData2[start...].range(of: ".m3u8")!.upperBound
                let unparsedVariantUrl = strData[start2..<end2]
                let variantUrl = unparsedVariantUrl.replacingOccurrences(of: "\n", with: "")
                // Prepare the new variant video url
                let videoUrlString = videoUrl.absoluteString
                let replaceString = String(videoUrl.lastPathComponent!)
                if let unwrappedVideoUrlString = videoUrlString {
                    let newVideoUrlString = unwrappedVideoUrlString.replacingOccurrences(of: replaceString, with: variantUrl)
                    let pathURL = NSURL(string: newVideoUrlString)!
                    // Push the newly compiled variant video URL through this method
                    self.getAssetID(videoUrl: pathURL){
                    }
                }
            } else {
                // Nothing we understand, yet
                let message = ["getAssetID": "Unable to parse URI from manifest. EXT-X-SESSION-KEY, EXT-X-KEY, or variant not found."]
                print(message)
            }
        }
    }
}
