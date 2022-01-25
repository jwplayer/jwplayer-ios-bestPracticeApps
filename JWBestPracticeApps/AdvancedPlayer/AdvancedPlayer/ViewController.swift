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
// 2. Add a custom progress bar
// 3. Add a custom play/pause button
// 4. Add a custom skip button
// 5. Add a custom fullscreen button
// 6. Add a custom learn more button
// 7. Observer for 'onFirstFrame' event. 'didFinishLoadingWithTime' is analogous to the `onFirstFrame` event in version 3.x.
// 8. Detect whether an upcoming ad is skippable
// 9. Time observation for content
// 10. Time observation for ads

class ViewController: JWPlayerViewController, JWPlayerViewControllerDelegate {

    private let videoUrlString = "https://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8"
    private let posterUrlString = "https://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg"

    // custom UI
    var playPauseButton: UIButton!
    var skipButton: UIButton!
    var progressBar: UISlider!
    var fullscreenButton: UIButton!
    var learnMoreButton: UIButton!
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

        addProgressBar(toView: view)
        addPlayPauseButton(toView: view)
        addSkipButton(toView: view)
        addFullscreenButton(toView: view)
        addLearnMoreButton(toView: view)

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

    // MARK: - 2. Add a custom progress bar

    private func addProgressBar(toView view: UIView) {
        progressBar = UISlider(frame: CGRect(x: 0, y: 0, width: view.frame.width - 40, height: 5))
        progressBar.addTarget(self, action: #selector(progressBarTouchDown(_:)), for: .touchDown)
        progressBar.addTarget(self, action: #selector(progressBarTouchUp(_:)), for: .touchUpInside)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.tintColor = .red
        progressBar.backgroundColor = .lightGray
        view.addSubview(progressBar)
        progressBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        progressBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        progressBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
    }

    @objc func progressBarTouchDown(_ sender: UISlider) {
        progressBarScrubbing = true
    }

    @objc func progressBarTouchUp(_ sender: UISlider) {
        player.seek(to: Double(progressBar.value))
        progressBarScrubbing = false
    }

    // MARK: - 3. Add a custom play/pause button

    private func addPlayPauseButton(toView view: UIView) {
        playPauseButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTap(_:)), for: .touchUpInside)
        if player.getState() == .playing {
            playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.backgroundColor = .white
        view.addSubview(playPauseButton)
        playPauseButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        playPauseButton.bottomAnchor.constraint(equalTo: progressBar.topAnchor, constant: -20).isActive = true
        playPauseButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    @objc func playPauseButtonTap(_ button: UIButton) {
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
            self?.playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
    }

    override func jwplayer(_ player: JWPlayer, isPlayingWithReason reason: JWPlayReason) {
        super.jwplayer(player, isPlayingWithReason: reason)
        DispatchQueue.main.async { [weak self] in
            self?.playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        }
    }

    // MARK: - 4. Add a custom skip button

    private func addSkipButton(toView view: UIView) {
        skipButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        skipButton.addTarget(self, action: #selector(skipButtonTap(_:)), for: .touchUpInside)
        skipButton.setTitle("Skip Ad", for: .normal)
        skipButton.setTitleColor(.blue, for: .normal)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.backgroundColor = .white
        skipButton.isHidden = true
        view.addSubview(skipButton)
        skipButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 100).isActive = true
        skipButton.bottomAnchor.constraint(equalTo: progressBar.topAnchor, constant: -20).isActive = true
        skipButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        skipButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    @objc func skipButtonTap(_ button: UIButton) {
        player.skipAd()
    }

    // MARK: - 5. Add a custom fullscreen button

    private func addFullscreenButton(toView view: UIView) {
        fullscreenButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        fullscreenButton.addTarget(self, action: #selector(fullscreenButtonTap(_:)), for: .touchUpInside)
        fullscreenButton.setTitle("Fullscreen", for: .normal)
        fullscreenButton.setTitleColor(.blue, for: .normal)
        fullscreenButton.translatesAutoresizingMaskIntoConstraints = false
        fullscreenButton.backgroundColor = .white
        view.addSubview(fullscreenButton)
        fullscreenButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        fullscreenButton.bottomAnchor.constraint(equalTo: progressBar.topAnchor, constant: -20).isActive = true
        fullscreenButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        fullscreenButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    @objc func fullscreenButtonTap(_ button: UIButton) {
        if isFullScreen {
            dismissFullScreen(animated: true, completion: nil)
        } else {
            transitionToFullScreen(animated: true, completion: nil)
        }
    }

    // MARK: - 6. Add a custom learn more button

    private func addLearnMoreButton(toView view: UIView) {
        learnMoreButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        learnMoreButton.addTarget(self, action: #selector(learnMoreButtonTap(_:)), for: .touchUpInside)
        learnMoreButton.setTitle("Learn more", for: .normal)
        learnMoreButton.setTitleColor(.blue, for: .normal)
        learnMoreButton.translatesAutoresizingMaskIntoConstraints = false
        learnMoreButton.backgroundColor = .white
        learnMoreButton.isHidden = true
        view.addSubview(learnMoreButton)
        learnMoreButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        learnMoreButton.bottomAnchor.constraint(equalTo: fullscreenButton.topAnchor, constant: -12).isActive = true
        learnMoreButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        learnMoreButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    @objc func learnMoreButtonTap(_ button: UIButton) {
        player.openAdClickthrough()
    }

    // MARK: - 7. Observer for 'onFirstFrame' event. 'didFinishLoadingWithTime' is analogous to the `onFirstFrame` event in version 3.x.

    override func jwplayer(_ player: JWPlayer, didFinishLoadingWithTime loadTime: TimeInterval) {
        super.jwplayer(player, didFinishLoadingWithTime: loadTime)

    }

    override func jwplayer(_ player: AnyObject, adEvent event: JWAdEvent) {
        super.jwplayer(player, adEvent: event)


        print("Ad Event type: \(event[.type] ?? "unknown")")

        switch event.type {
        case .impression, .meta:
            // MARK: - 8. Detect whether an upcoming ad is skippable
            // If the ad has a skip offset >= 0, it's skippable.
            if let skipOffset = event[.skipOffset] as? TimeInterval, skipOffset >= 0 {
                self.skipOffset = skipOffset
                DispatchQueue.main.async { [weak self] in
                    self?.skipButton.isHidden = false
                }
            }
        case .adBreakStart:
            DispatchQueue.main.async { [weak self] in
                self?.learnMoreButton.isHidden = false
                self?.progressBar.tintColor = .orange
                self?.progressBar.isUserInteractionEnabled = false
            }
        case .adBreakEnd:
            DispatchQueue.main.async { [weak self] in
                self?.learnMoreButton.isHidden = true
                self?.progressBar.tintColor = .red
                self?.progressBar.isUserInteractionEnabled = true
            }
        case .complete:
            DispatchQueue.main.async { [weak self] in
                self?.skipButton.isHidden = true
            }
        case .play:
            DispatchQueue.main.async { [weak self] in
                self?.playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
            }
        case .pause:
            DispatchQueue.main.async { [weak self] in
                self?.playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
            }
        case .skipped:
            DispatchQueue.main.async { [weak self] in
                self?.learnMoreButton.isHidden = true
                self?.progressBar.tintColor = .red
                self?.progressBar.isUserInteractionEnabled = true
                self?.skipButton.isHidden = true
            }
        default:
            return
        }
    }

    // MARK: - 9. Time observation for content

    override func onMediaTimeEvent(_ time: JWTimeData) {
        super.onMediaTimeEvent(time)
        if progressBarScrubbing == false {
            progressBar.maximumValue = Float(time.duration)
            progressBar.value = Float(time.position)
        }
    }


    // MARK: - 10. Time observation for ads

    override func onAdTimeEvent(_ time: JWTimeData) {
        super.onAdTimeEvent(time)
        progressBar.maximumValue = Float(time.duration)
        progressBar.value = Float(time.position)

        guard skipOffset != nil,
              skipOffset! - time.position > 0 else {
                  skipButton.setTitle("Skip Ad", for: .normal)
                  return
              }

        let timeRemaining = Int(ceil(skipOffset! - time.position))
        skipButton.setTitle("Skip Ad in \(timeRemaining)", for: .normal)
    }

    // MARK: - JWPlayerViewControllerDelegate

    func playerViewControllerWillGoFullScreen(_ controller: JWPlayerViewController) -> JWFullScreenViewController? {
        playPauseButton.removeFromSuperview()
        skipButton.removeFromSuperview()
        fullscreenButton.removeFromSuperview()
        progressBar.removeFromSuperview()

        self.fullScreenVC = JWFullScreenViewController()
        return self.fullScreenVC
    }

    func playerViewControllerDidGoFullScreen(_ controller: JWPlayerViewController) {
        addProgressBar(toView: fullScreenVC!.view)
        addPlayPauseButton(toView: fullScreenVC!.view)
        addSkipButton(toView: fullScreenVC!.view)
        addFullscreenButton(toView: fullScreenVC!.view)
    }

    func playerViewControllerWillDismissFullScreen(_ controller: JWPlayerViewController) {
        playPauseButton.removeFromSuperview()
        skipButton.removeFromSuperview()
        fullscreenButton.removeFromSuperview()
        progressBar.removeFromSuperview()
    }

    func playerViewControllerDidDismissFullScreen(_ controller: JWPlayerViewController) {
        addProgressBar(toView: view)
        addPlayPauseButton(toView: view)
        addSkipButton(toView: view)
        addFullscreenButton(toView: view)
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

