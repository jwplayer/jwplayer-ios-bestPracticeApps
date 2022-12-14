//
//  ViewController.swift
//  Offline DRM
//
//  Created by David Perez on 02/12/22.
//

import JWPlayerKit
import AVFoundation

class ViewController: UIViewController, AVAssetDownloadDelegate {
    // MARK: - IBOutlet
    /// Presents the current state of the offline media.
    @IBOutlet private weak var stateLabel: UILabel?
    
    // MARK: - Properties
   
    /// The key for requesting the data from UserDefaults.
    private let savedDataKey = "localVideoFile"

    // MARK: - DRM management properties

    /// The content key loader.
    private var contentLoader: JWDRMContentLoader?
    private let keyManager: JWDRMContentKeyManager = DRMKeyManager()
    private let keyDataSource: DRMKeyDataSource = DRMKeyDataSource()

    // MARK: - Playlist properties
    private let playlistURL = "{SIGNED_URL}"

    /// The playlist signed URL for DRM protected content.
    /// The video file from the signed URL, this gets set after parsing the playlist.
    private var videoFile = ""
    /// The location in memory for the local video, this gets set when downloading the asset. Not directly used.
    private var localVideoFile: URL? = nil
    /// The local video URL, this gets set from memory if the video is saved and used as the locator for on-device videos. Bookmarked data allows us to access the video file in memory since it is stored in a secure location.
    private var localURL: URL? {
        let persistedData = UserDefaults.standard.data(forKey: savedDataKey)
        guard let boomarkData = persistedData else {
            return nil
        }
        var dataStaleStatus = false
        let url = try? URL(resolvingBookmarkData: boomarkData,
                           bookmarkDataIsStale: &dataStaleStatus)
        return dataStaleStatus ? nil : url
    }
    /// The player interface, this is from the JWPlayerViewController embedded in a container view.
    private var player: JWPlayerProtocol? = nil
    
    /// The AVAssetDownloadURLSession to use for managing AVAssetDownloadTasks.
    private var assetDownloadURLSession: AVAssetDownloadURLSession!
    /// The delegate queue for the AVAssetDownloadURLSession
    private let delegateQueue = OperationQueue()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// The keys can be pre-loaded by calling load on the content loader.
        let url = URL(string: playlistURL)!
        contentLoader = JWDRMContentLoader(dataSource: keyDataSource, keyManager: keyManager)
        self.contentLoader?.load(playlist: url)
        
        // We construct a playlist either from the remote asset or a local asset if it is saved.
        var config: JWPlayerConfiguration!
        
        if let localURL = localURL {
            config = self.getPlaylist(local: localURL)
            // Updates the UI to reflect that the asset is already downloaded.
            stateLabel?.text = "Saved"
        } else {
            config = self.getPlaylist(remote: url)
        }
        // We set the content loader to the player.
        self.player?.contentLoader = self.contentLoader
        // We configure the player.
        self.player?.configurePlayer(with: config)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create the configuration for the AVAssetDownloadURLSession.
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "AAPL-Identifier")
        assetDownloadURLSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration,
                                                            assetDownloadDelegate: self, delegateQueue: delegateQueue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let playerViewController = segue.destination as? JWPlayerViewController else {
            return
        }
        // Set this controller's player reference to the embedded JWPlayerViewController's.
        self.player = playerViewController.player
    }
    
    /**
     Creates a player configuration from the JW Player playlist URL.

     The signed URL you generate for [content protection](https://docs.jwplayer.com/platform/reference/protect-your-content-with-signed-urls#create-a-signed-jwt-url)
     returns a JSON playlist we can use to configure the player.
     - parameter url: The signed URL for the content playlist.
     */
    func getPlaylist(remote url: URL) -> JWPlayerConfiguration? {
        let sem = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, err in
            defer {
                sem.signal()
            }
            guard let self = self else {
                return
            }
            if let error = err {
                fatalError("Playlist URL request failed: \(error.localizedDescription)")
            }
            do {
                // We try to decode the playlist data into a playlist struct. [more info](https://docs.jwplayer.com/platform/reference/protect-your-content-with-signed-urls#create-a-signed-jwt-url)
                let playlist = try JSONDecoder().decode(DRMPlaylist.self, from: data!)
                // We are only interested in the source that is an m3u8 file.
                // Other source will contains formats compatible with Widevine and PlayReady.
                guard let source = playlist.playlist.first?.sources.first(where: { $0.type == "application/vnd.apple.mpegurl" }) else {
                    return
                }
                // After parsing the playlist, set the current video file
                self.videoFile = source.file
                // Set the certificate URL we will need for for the JWDRMKeyDataSource, this is part of the FairPlay property in the used source.
                self.keyDataSource.certificateURLStr = source.drm.fairplay?.certificateURL
                // Set the process SPC URL we will need for for the JWDRMKeyDataSource, this is part of the FairPlay property in the used source.
                self.keyDataSource.processSPCURLStr = source.drm.fairplay?.processSpcURL
            } catch {
                print("Error decoding data from playlist URL", error.localizedDescription)
            }
        }
        task.resume()
        sem.wait()
        // Create a configuration from the video file.
        let fileURL = URL(string: videoFile)!
        var config: JWPlayerConfiguration? = nil
        do {
            let playerItem = try JWPlayerItemBuilder().file(fileURL).build()
            config = try JWPlayerConfigurationBuilder()
                .playlist(items: [playerItem]).build()
        } catch {
            // Handle any error thrown during the configuration build
            print("Error encountered while building the configuration:", error.localizedDescription)
        }
       
        return config
    }
    
    /**
     Creates a player configuration from the locally saved video file.
     
     The URL is specified by the `AVAssetDownloadTask` or `AVAggregateAssetDownloadTask`, and received by the `willDownloadTo` delegate method.
     - parameter url: A url for a video in the device file system.
     */
    func getPlaylist(local url: URL) -> JWPlayerConfiguration? {
        var config: JWPlayerConfiguration? = nil
        do {
            let playerItem = try JWPlayerItemBuilder().file(url).build()
            config = try JWPlayerConfigurationBuilder()
                .playlist(items: [playerItem]).build()
        } catch {
            // Handle any error thrown during the configuration build
            print("Error encountered while building the configuration:", error.localizedDescription)
        }

        return config
    }
    
    /// Triggers the initial AVAssetDownloadTask for a given Asset.
    func downloadStream(for asset: AVURLAsset) {
        // Get the default media selections for the asset's media selection groups.
        let preferredMediaSelection = asset.preferredMediaSelection
        
        /*
         Creates and initializes an AVAggregateAssetDownloadTask to download multiple AVMediaSelections
         on an AVURLAsset.
         
         For the initial download, we ask the URLSession for an AVAssetDownloadTask with a minimum bitrate
         corresponding with one of the lower bitrate variants in the asset.
         */
        guard let task =
                assetDownloadURLSession.aggregateAssetDownloadTask(with: asset,
                                                                   mediaSelections: [preferredMediaSelection],
                                                                   assetTitle: asset.description,
                                                                   assetArtworkData: nil,
                                                                   options:
                                                                    [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265_000]) else {
            return
        }
        
        task.resume()
    }
    
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask, didCompleteFor mediaSelection: AVMediaSelection) {
        // An error if we failed to save the data bookmark
        var bookmarkError: String? = nil
        do {
            let data = try localVideoFile?.bookmarkData()
            UserDefaults.standard.set(data, forKey: savedDataKey)
        } catch {
            bookmarkError = "Error saving, try again"
        }
        DispatchQueue.main.async { [weak self] in
            self?.stateLabel?.text = bookmarkError ?? "Saved"
        }
    }
    
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask, willDownloadTo location: URL) {
        localVideoFile = location
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Error while downloading the asset: ", error.localizedDescription)
            DispatchQueue.main.async { [weak self] in
                self?.stateLabel?.text = "Error donwloading, try again"
            }

        }
    }

    /// Starts an download session for the provided AVURLAsset.
    @IBAction func downloadStream(_ sender: UIButton) {
        guard let video = URL(string: videoFile) else {
            return
        }
        // If we have a video file, start downloading the asset.
        let asset = AVURLAsset(url: video)
        downloadStream(for: asset)
        stateLabel?.text = "Downloading"
    }

    /**
     If the keys have expired, or you wish to download this again.
     
     This removes any previous values and then configures the player with a JW Player playlist URL.
     */
    @IBAction func resetStream(_ sender: UIButton) {
        // Delete downloaded file
        if let localURL = localURL {
            do {
                try FileManager.default.removeItem(at: localURL)
            } catch {
                print("Could not delete local URL")
            }
        }
        // Delete persisted keys
        if let keyManager = keyManager as? DRMKeyManager {
            do {
                try FileManager.default.removeItem(atPath: keyManager.keyDirectory.relativePath)
            } catch {
                print("Could not delete local URL")
            }
        }
        // Update UI
        stateLabel?.text = ""
        // Setup the player again, with the remote playlist.
        let playlistURL = URL(string: playlistURL)!
        if let config = self.getPlaylist(remote: playlistURL) {
            self.player?.configurePlayer(with: config)
        }
    }
}

