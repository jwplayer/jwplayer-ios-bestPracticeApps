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

    // custom UI
    var customControls: CustomControls!
    var progressBarScrubbing: Bool = false
    var skipOffset: Double?
    var fullScreenVC: JWFullScreenViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        // Set the view's background color to black for better contrast.
        view.backgroundColor = .black

        // MARK: - 1. Hide & disable built-in controls/ad controls
        interfaceBehavior = .hidden

        // MARK: - 2. Add custom controls
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

        let advertisingConfigBuilder = JWAdsAdvertisingConfigBuilder()
            .vmapURL(URL(string: "https://s3.amazonaws.com/george.success.jwplayer.com/demos/vmap_midroll_preroll.xml")!)
        var advertisingConfig: JWAdvertisingConfig!
        do {
            advertisingConfig = try advertisingConfigBuilder.build()
        } catch {
            // Handle advertising config build failure
            print(error.localizedDescription)
            return
        }

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

        player.configurePlayer(with: config)
    }

    // MARK: - Add custom controls

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
        DispatchQueue.main.async { [weak self] in
            self?.customControls.playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
    }

    override func jwplayer(_ player: JWPlayer, isPlayingWithReason reason: JWPlayReason) {
        super.jwplayer(player, isPlayingWithReason: reason)
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

    // MARK: - 3. Observer for 'didFinishLoadingWithTime' event. 'didFinishLoadingWithTime' is analogous to the `onFirstFrame` event in version 3.x.

    override func jwplayer(_ player: JWPlayer, didFinishLoadingWithTime loadTime: TimeInterval) {
        super.jwplayer(player, didFinishLoadingWithTime: loadTime)

    }

    override func jwplayer(_ player: AnyObject, adEvent event: JWAdEvent) {
        super.jwplayer(player, adEvent: event)


        print("Ad Event type: \(event[.type] ?? "unknown")")

        switch event.type {
        case .impression, .meta:
            // MARK: - 4. Detect whether an upcoming ad is skippable
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

    // MARK: - 5. Time observation for content

    override func onMediaTimeEvent(_ time: JWTimeData) {
        super.onMediaTimeEvent(time)
        if progressBarScrubbing == false {
            DispatchQueue.main.async { [weak self] in
                self?.customControls.progressBar.maximumValue = Float(time.duration)
                self?.customControls.progressBar.value = Float(time.position)
            }
        }
    }


    // MARK: - 6. Time observation for ads

    override func onAdTimeEvent(_ time: JWTimeData) {
        super.onAdTimeEvent(time)
        DispatchQueue.main.async { [weak self] in
            self?.customControls.progressBar.maximumValue = Float(time.duration)
            self?.customControls.progressBar.value = Float(time.position)

            guard self?.skipOffset != nil,
                  self!.skipOffset! - time.position > 0 else {
                      self?.customControls.skipButton.setTitle("Skip Ad", for: .normal)
                      return
                  }

            let timeRemaining = Int(ceil(self!.skipOffset! - time.position))
            self?.customControls.skipButton.setTitle("Skip Ad in \(timeRemaining)", for: .normal)
        }
    }

    // MARK: - JWPlayerViewControllerDelegate

    func playerViewControllerWillGoFullScreen(_ controller: JWPlayerViewController) -> JWFullScreenViewController? {

        self.fullScreenVC = JWFullScreenViewController()
        return self.fullScreenVC
    }

    func playerViewControllerDidGoFullScreen(_ controller: JWPlayerViewController) {
        guard let fullScreenVC = fullScreenVC else {
            return
        }

        addCustomControls(toView: fullScreenVC.view)
    }

    func playerViewControllerWillDismissFullScreen(_ controller: JWPlayerViewController) {

    }

    func playerViewControllerDidDismissFullScreen(_ controller: JWPlayerViewController) {
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

