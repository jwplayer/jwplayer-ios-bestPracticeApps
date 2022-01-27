//
//  CustomControls.swift
//  AdvancedPlayer
//
//  Created by Michael Salvador on 1/25/22.
//

import UIKit

protocol CustomControlsDelegate: AnyObject  {
    func playPauseButtonTap(_ button: UIButton)
    func skipButtonTap(_ button: UIButton)
    func learnMoreButtonTap(_ button: UIButton)
    func fullscreenButtonTap(_ button: UIButton)
    func progressBarTouchDown(_ slider: UISlider)
    func progressBarTouchUp(_ slider: UISlider)
}

class CustomControls: UIView {

    weak var delegate: CustomControlsDelegate?

    @IBOutlet weak var progressBar: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var fullscreenButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        progressBar.addTarget(self, action: #selector(progressBarTouchDown(_:)), for: .touchDown)
        progressBar.addTarget(self, action: #selector(progressBarTouchUp(_:)), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc func progressBarTouchDown(_ sender: UISlider) {
        delegate?.progressBarTouchDown(sender)
    }

    @objc func progressBarTouchUp(_ sender: UISlider) {
        delegate?.progressBarTouchUp(sender)
    }

    @IBAction func playPauseButtonTap(_ sender: Any) {
        guard let sender = sender as? UIButton else { return }
        delegate?.playPauseButtonTap(sender)
    }

    @IBAction func skipButtonTap(_ sender: Any) {
        guard let sender = sender as? UIButton else { return }
        delegate?.skipButtonTap(sender)
    }

    @IBAction func learnMoreButtonTap(_ sender: Any) {
        guard let sender = sender as? UIButton else { return }
        delegate?.learnMoreButtonTap(sender)
    }

    @IBAction func fullscreenButtonTap(_ sender: Any) {
        guard let sender = sender as? UIButton else { return }
        delegate?.fullscreenButtonTap(sender)
    }
}
