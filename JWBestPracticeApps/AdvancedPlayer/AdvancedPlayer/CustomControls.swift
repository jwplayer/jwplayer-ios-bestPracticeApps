//
//  CustomControls.swift
//  AdvancedPlayer
//
//  Created by Michael Salvador on 1/25/22.
//

import UIKit

// Responder to interaction with custom controls
protocol CustomControlsDelegate: AnyObject  {
    func playPauseButtonTap(_ button: UIButton)
    func skipButtonTap(_ button: UIButton)
    func learnMoreButtonTap(_ button: UIButton)
    func fullscreenButtonTap(_ button: UIButton)
    func progressBarTouchDown(_ slider: UISlider)
    func progressBarTouchUp(_ slider: UISlider)
}

/**
 Custom controls to overlay on the player view
 */
class CustomControls: UIView {

    // The receiver of callbacks when a user interacts with custom controls
    weak var delegate: CustomControlsDelegate?

    @IBOutlet weak var progressBar: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var fullscreenButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Add targets to the progress bar to listen for touchDown and touchUpInside events
        progressBar.addTarget(self, action: #selector(progressBarTouchDown(_:)), for: .touchDown)
        progressBar.addTarget(self, action: #selector(progressBarTouchUp(_:)), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Inform the CustomControlsDelegate when the progress bar touchDown event occurs
    @objc func progressBarTouchDown(_ sender: UISlider) {
        delegate?.progressBarTouchDown(sender)
    }

    // Inform the CustomControlsDelegate when the progress bar touchUpInside event occurs
    @objc func progressBarTouchUp(_ sender: UISlider) {
        delegate?.progressBarTouchUp(sender)
    }

    // Inform the CustomControlsDelegate when the play/pause button is tapped
    @IBAction func playPauseButtonTap(_ sender: Any) {
        guard let sender = sender as? UIButton else { return }
        delegate?.playPauseButtonTap(sender)
    }

    // Inform the CustomControlsDelegate when the skip button is tapped
    @IBAction func skipButtonTap(_ sender: Any) {
        guard let sender = sender as? UIButton else { return }
        delegate?.skipButtonTap(sender)
    }

    // Inform the CustomControlsDelegate when the learn more button is tapped
    @IBAction func learnMoreButtonTap(_ sender: Any) {
        guard let sender = sender as? UIButton else { return }
        delegate?.learnMoreButtonTap(sender)
    }

    // Inform the CustomControlsDelegate when the fullscreen button is tapped
    @IBAction func fullscreenButtonTap(_ sender: Any) {
        guard let sender = sender as? UIButton else { return }
        delegate?.fullscreenButtonTap(sender)
    }
}
