//
//  ViewController.swift
//  AdvancedPlayer
//
//  Created by Michael Salvador on 1/20/22.
//

import UIKit
import JWPlayerKit
import AVFoundation

// This best practices app demonstrates the following functionality (search for instances of text below to find relevant code)
// 1. Hide & disable built-in controls/ad controls
// 2. Add custom controls
// 3. Observer for 'didFinishLoadingWithTime' event. 'didFinishLoadingWithTime' is analogous to the `onFirstFrame` event in version 3.x.
// 4. Detect whether an upcoming ad is skippable
// 5. Time observation for content
// 6. Time observation for ads

class ViewController: JWPlayerViewController,
                      JWPlayerViewControllerDelegate,
                      CustomControlsDelegate {

    private let videoUrlString = "https://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8"
    private let posterUrlString = "https://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg"

    // Custom controls to overlay on the player
    var customControls: CustomControls!
    // Whether or not user is currently dragging scrub bar
    var progressBarScrubbing: Bool = false
    // The skip offset of the current ad
    var skipOffset: Double?
    // The view controller that manages the fullscreen mode
    var fullScreenVC: JWFullScreenViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        // Set the view's background color to black for better contrast.
        view.backgroundColor = .black

        // MARK: 1. Hide & disable built-in controls/ad controls
        interfaceBehavior = .hidden

        // MARK: 2. Add custom controls
        customControls = UINib(nibName: "CustomControls", bundle: .main).instantiate(withOwner: nil, options: nil).first as? CustomControls
        customControls.translatesAutoresizingMaskIntoConstraints = false
        customControls.delegate = self
        addCustomControls(toView: view)

        // Set up the player.
        setUpPlayer()
    }

    /**
     Sets up the player with a simple configuration.
     */
    private func setUpPlayer() {
        let videoUrl = URL(string:videoUrlString)!
        let posterUrl = URL(string:posterUrlString)!

        // First, create the player item
        let playerItembuilder = JWPlayerItemBuilder()
            .file(videoUrl)
            .posterImage(posterUrl)
        var playerItem: JWPlayerItem!
        do {
            playerItem = try playerItembuilder.build()
        } catch {
            // Handle player item build failure
            print(error.localizedDescription)
            return
        }

        // Second, create an advertising configuation. In this case, we're providing a VMAP URL.
        let advertisingConfigBuilder = JWAdsAdvertisingConfigBuilder()
            .vmapURL(URL(string: "https://playertest.longtailvideo.com.s3.amazonaws.com/vmap/vmap-schedule-pre-mid-post.xml")!)
        var advertisingConfig: JWAdvertisingConfig!
        do {
            advertisingConfig = try advertisingConfigBuilder.build()
        } catch {
            // Handle advertising config build failure
            print(error.localizedDescription)
            return
        }

        // Third, create a player configuration, supplying the created player item and advertising configuration.
        let configBuilder = JWPlayerConfigurationBuilder()
            .playlist([playerItem])
            .advertising(advertisingConfig)
        var config: JWPlayerConfiguration!
        do {
            config = try configBuilder.build()
        } catch {
            // Handle player item build failure
            print(error.localizedDescription)
            return
        }

        // Configure the player using the created player configuration.
        player.configurePlayer(with: config)
    }

    /**
     Remove custom controls from superview, and add them to passed view.
     */
    func addCustomControls(toView view: UIView) {
        customControls.removeFromSuperview()
        view.addSubview(customControls)
        customControls.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        customControls.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        customControls.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        customControls.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    // MARK: - CustomControlsDelegate

    func progressBarTouchUp(_ slider: UISlider) {
        // When a user removes their finger from the progress bar, seek to the point
        // of progress
        player.seek(to: Double(customControls.progressBar.value))
        progressBarScrubbing = false
    }

    func progressBarTouchDown(_ slider: UISlider) {
        progressBarScrubbing = true
    }

    func playPauseButtonTap(_ button: UIButton) {
        let state = player.getState()
        if state == .playing {
            player.pause()
        } else {
            player.play()
        }
    }

    override func jwplayer(_ player: JWPlayer, didPauseWithReason reason: JWPauseReason) {
        super.jwplayer(player, didPauseWithReason: reason)
        // Set the play/pause button image on the main thread
        DispatchQueue.main.async { [weak self] in
            self?.customControls.playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
    }

    override func jwplayer(_ player: JWPlayer, isPlayingWithReason reason: JWPlayReason) {
        super.jwplayer(player, isPlayingWithReason: reason)
        // Set the play/pause button image on the main thread
        DispatchQueue.main.async { [weak self] in
            self?.customControls.playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        }
    }

    func skipButtonTap(_ button: UIButton) {
        player.skipAd()
    }

    func learnMoreButtonTap(_ button: UIButton) {
        player.openAdClickthrough()
    }

    func fullscreenButtonTap(_ button: UIButton) {
        if isFullScreen {
            dismissFullScreen(animated: true, completion: nil)
        } else {
            transitionToFullScreen(animated: true, completion: nil)
        }
    }

    // MARK: 3. Observer for 'didFinishLoadingWithTime' event. 'didFinishLoadingWithTime' is analogous to the `onFirstFrame` event in version 3.x.

    override func jwplayer(_ player: JWPlayer, didFinishLoadingWithTime loadTime: TimeInterval) {
        super.jwplayer(player, didFinishLoadingWithTime: loadTime)

    }

    // MARK: - Observer ad events

    override func jwplayer(_ player: AnyObject, adEvent event: JWAdEvent) {
        super.jwplayer(player, adEvent: event)


        print("Ad Event type: \(event[.type] ?? "unknown")")

        switch event.type {
        case .impression, .meta:
            // MARK: 4. Detect whether an upcoming ad is skippable
            // If the ad has a skip offset >= 0, it's skippable.
            if let skipOffset = event[.skipOffset] as? TimeInterval, skipOffset >= 0 {
                self.skipOffset = skipOffset
                DispatchQueue.main.async { [weak self] in
                    self?.customControls.skipButton.isHidden = false
                }
            }
        case .adBreakStart:
            DispatchQueue.main.async { [weak self] in
                self?.customControls.learnMoreButton.isHidden = false
                self?.customControls.progressBar.tintColor = .orange
                self?.customControls.progressBar.isUserInteractionEnabled = false
            }
        case .adBreakEnd:
            DispatchQueue.main.async { [weak self] in
                self?.customControls.learnMoreButton.isHidden = true
                self?.customControls.progressBar.tintColor = .red
                self?.customControls.progressBar.isUserInteractionEnabled = true
            }
        case .complete:
            DispatchQueue.main.async { [weak self] in
                self?.customControls.skipButton.isHidden = true
            }
        case .play:
            DispatchQueue.main.async { [weak self] in
                self?.customControls.playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
            }
        case .pause:
            DispatchQueue.main.async { [weak self] in
                self?.customControls.playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
            }
        case .skipped:
            DispatchQueue.main.async { [weak self] in
                self?.customControls.learnMoreButton.isHidden = true
                self?.customControls.progressBar.tintColor = .red
                self?.customControls.progressBar.isUserInteractionEnabled = true
                self?.customControls.skipButton.isHidden = true
            }
        default:
            return
        }
    }

    // MARK: 5. Time observation for content

    override func onMediaTimeEvent(_ time: JWTimeData) {
        super.onMediaTimeEvent(time)
        // If the user is not scrubbing, update the progress bar to reflect the current
        // playback position
        if progressBarScrubbing == false {
            DispatchQueue.main.async { [weak self] in
                self?.customControls.progressBar.maximumValue = Float(time.duration)
                self?.customControls.progressBar.value = Float(time.position)
            }
        }
    }


    // MARK: 6. Time observation for ads

    override func onAdTimeEvent(_ time: JWTimeData) {
        super.onAdTimeEvent(time)
        // Update the progress bar to reflect the new playback position of the ad
        DispatchQueue.main.async { [weak self] in
            self?.customControls.progressBar.maximumValue = Float(time.duration)
            self?.customControls.progressBar.value = Float(time.position)

            // If there is no skip offset, set the skip button title to "Skip Ad"
            guard self?.skipOffset != nil,
                  self!.skipOffset! - time.position > 0 else {
                      self?.customControls.skipButton.setTitle("Skip Ad", for: .normal)
                      return
                  }

            // If there is a skip offset, set the skip button title to reflect how much time the developer has
            // before they can skip
            let timeRemaining = Int(ceil(self!.skipOffset! - time.position))
            self?.customControls.skipButton.setTitle("Skip Ad in \(timeRemaining)", for: .normal)
        }
    }

    // MARK: - JWPlayerViewControllerDelegate

    func playerViewControllerWillGoFullScreen(_ controller: JWPlayerViewController) -> JWFullScreenViewController? {
        // Create and retain a JWFullScreenViewController that we can use to add custom controls to
        self.fullScreenVC = JWFullScreenViewController()
        return self.fullScreenVC
    }

    func playerViewControllerDidGoFullScreen(_ controller: JWPlayerViewController) {
        // When the player goes full screen, add our custom controls to the JWFullScreenViewController's view
        guard let fullScreenVC = fullScreenVC else {
            return
        }

        addCustomControls(toView: fullScreenVC.view)
    }

    func playerViewControllerWillDismissFullScreen(_ controller: JWPlayerViewController) {

    }

    func playerViewControllerDidDismissFullScreen(_ controller: JWPlayerViewController) {
        // When the player leaves full sreen, add our custom controls to the JWPlayerViewController's view
        addCustomControls(toView: view)
    }

    func playerViewController(_ controller: JWPlayerViewController, controlBarVisibilityChanged isVisible: Bool, frame: CGRect) {

    }

    func playerViewController(_ controller: JWPlayerViewController, sizeChangedFrom oldSize: CGSize, to newSize: CGSize) {

    }

    func playerViewController(_ controller: JWPlayerViewController, screenTappedAt position: CGPoint) {

    }

    func playerViewController(_ controller: JWPlayerViewController, relatedMenuOpenedWithItems items: [JWPlayerItem], withMethod method: JWRelatedInteraction) {

    }

    func playerViewController(_ controller: JWPlayerViewController, relatedMenuClosedWithMethod method: JWRelatedInteraction) {

    }

    func playerViewController(_ controller: JWPlayerViewController, relatedItemBeganPlaying item: JWPlayerItem, atIndex index: Int, withMethod method: JWRelatedInteraction) {
        
    }
}

